use sea_orm::{
    ActiveModelTrait, ConnectOptions, Database, DatabaseConnection, EntityTrait, IntoActiveModel,
};
use std::{any::type_name_of_val, path::Path};
use thiserror::Error;

#[derive(Error, Debug)]
pub enum RepositoryError {
    #[error("Database error: {0}")]
    DBError(#[from] sea_orm::DbErr),

    #[error("IO error: {0}")]
    IOError(#[from] std::io::Error),
}

pub trait Repository {
    fn read<T>(&self) -> impl Future<Output = Result<T::Model, RepositoryError>> + Send + 'static
    where
        T: EntityTrait,
        T::Model: IntoActiveModel<T::ActiveModel> + Default,
        T::ActiveModel: Send;

    fn write<T>(
        &self,
        model: T::Model,
    ) -> impl Future<Output = Result<(), RepositoryError>> + Send + 'static
    where
        T: EntityTrait,
        T::Model: IntoActiveModel<T::ActiveModel>,
        T::ActiveModel: Send;
}

#[derive(Debug, Clone)]
pub struct DBManager(DatabaseConnection);

impl DBManager {
    pub(crate) async fn new(working_path: &Path) -> Result<Self, RepositoryError> {
        // Create working folder if it doesn't exist
        if !working_path.exists() {
            std::fs::create_dir(working_path)?;
        }

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

    #[cfg(test)]
    pub(crate) async fn new_memory_db() -> Result<Self, RepositoryError> {
        let db = Database::connect("sqlite::memory:").await?;
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
    fn read<T>(&self) -> impl Future<Output = Result<T::Model, RepositoryError>> + Send + 'static
    where
        T: EntityTrait,
        T::Model: IntoActiveModel<T::ActiveModel> + Default,
        T::ActiveModel: Send,
    {
        let connection = self.get_connection();
        async move {
            match T::find().one(&connection).await.inspect_err(|e| {
                log::error!("read from db error: {}", e);
            })? {
                Some(model) => Ok(model),
                None => {
                    let default = T::Model::default().into_active_model();
                    let default = default.insert(&connection).await.inspect_err(|e| {
                        log::error!("write to db error: {}", e);
                    })?;
                    Ok(default)
                }
            }
        }
    }

    fn write<T>(
        &self,
        model: T::Model,
    ) -> impl Future<Output = Result<(), RepositoryError>> + Send + 'static
    where
        T: EntityTrait,
        T::Model: IntoActiveModel<T::ActiveModel>,
        T::ActiveModel: Send,
    {
        log::debug!("write [{}] to db: {:#?}", type_name_of_val(&model), model);
        let connection = self.get_connection();
        async move {
            let active_model = model.into_active_model();
            let active_model = active_model.reset_all();
            active_model.update(&connection).await.inspect_err(|e| {
                log::error!("write to db error: {}", e);
            })?;
            Ok(())
        }
    }
}
