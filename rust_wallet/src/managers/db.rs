use crate::error::WalletError;
use sea_orm::{
    ActiveModelTrait, ConnectOptions, Database, DatabaseConnection, EntityTrait, IntoActiveModel,
};
use std::path::Path;

pub(crate) trait Repository {
    fn read<T>(&self) -> impl Future<Output = Result<T::Model, WalletError>> + Send + 'static
    where
        T: EntityTrait,
        T::Model: IntoActiveModel<T::ActiveModel> + Default,
        T::ActiveModel: Send;

    fn write<T>(
        &self,
        model: T::Model,
    ) -> impl Future<Output = Result<(), WalletError>> + Send + 'static
    where
        T: EntityTrait,
        T::Model: IntoActiveModel<T::ActiveModel>,
        T::ActiveModel: Send;
}

#[derive(Debug, Clone)]
pub(crate) struct DBManager(DatabaseConnection);

impl DBManager {
    pub(crate) async fn new(working_path: &Path) -> Result<Self, WalletError> {
        let db_url = format!(
            "sqlite://{}?mode=rwc",
            working_path.join("wallet.db").to_str().unwrap()
        );
        let mut opt = ConnectOptions::new(db_url);
        opt.sqlx_logging(false);

        let db = Database::connect(opt).await?;
        db.get_schema_registry(module_path!().split("::").next().unwrap())
            .sync(&db)
            .await?;
        Ok(Self(db))
    }

    pub(crate) fn get_connection(&self) -> DatabaseConnection {
        self.0.clone()
    }
}

impl Repository for DBManager {
    fn read<T>(&self) -> impl Future<Output = Result<T::Model, WalletError>> + Send + 'static
    where
        T: EntityTrait,
        T::Model: IntoActiveModel<T::ActiveModel> + Default,
        T::ActiveModel: Send,
    {
        let connection = self.get_connection();
        async move {
            match T::find().one(&connection).await? {
                Some(model) => Ok(model),
                None => {
                    let default = T::Model::default().into_active_model();
                    let default = default.insert(&connection).await?;
                    Ok(default)
                }
            }
        }
    }

    fn write<T>(
        &self,
        model: T::Model,
    ) -> impl Future<Output = Result<(), WalletError>> + Send + 'static
    where
        T: EntityTrait,
        T::Model: IntoActiveModel<T::ActiveModel>,
        T::ActiveModel: Send,
    {
        let connection = self.get_connection();
        async move {
            let active_model = model.into_active_model();
            let active_model = active_model.reset_all();
            active_model.update(&connection).await?;
            Ok(())
        }
    }
}
