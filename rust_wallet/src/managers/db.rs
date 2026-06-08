use sea_orm::{
    ActiveModelTrait, ConnectOptions, Database, DatabaseConnection, EntityTrait, IntoActiveModel,
};
use std::{
    any::type_name_of_val,
    path::{Path, PathBuf},
};
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

    fn reset(&self) -> impl Future<Output = Result<(), RepositoryError>> + Send + 'static;
}

#[derive(Debug, Clone)]
pub struct DBManager {
    connection: DatabaseConnection,
    db_path: Option<PathBuf>,
}

impl DBManager {
    pub(crate) async fn new(working_path: &Path) -> Result<Self, RepositoryError> {
        // Create working folder if it doesn't exist
        if !working_path.exists() {
            std::fs::create_dir(working_path)?;
        }

        let db_path = working_path.join("wallet.db");

        let db_url = format!("sqlite://{}?mode=rwc", db_path.to_str().unwrap());
        let mut opt = ConnectOptions::new(db_url);
        opt.sqlx_logging(false);

        let connection = Database::connect(opt).await?;
        connection
            .get_schema_registry(module_path!().split("::").next().unwrap())
            .sync(&connection)
            .await?;
        Ok(Self {
            connection,
            db_path: Some(db_path),
        })
    }

    #[cfg(test)]
    pub(crate) async fn new_memory_db() -> Result<Self, RepositoryError> {
        let db = Database::connect("sqlite::memory:").await?;
        db.get_schema_registry(module_path!().split("::").next().unwrap())
            .sync(&db)
            .await?;
        Ok(Self {
            connection: db,
            db_path: None,
        })
    }
}

impl Repository for DBManager {
    fn read<T>(&self) -> impl Future<Output = Result<T::Model, RepositoryError>> + Send + 'static
    where
        T: EntityTrait,
        T::Model: IntoActiveModel<T::ActiveModel> + Default,
        T::ActiveModel: Send,
    {
        let connection = self.connection.clone();
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
        let connection = self.connection.clone();
        async move {
            let active_model = model.into_active_model();
            let active_model = active_model.reset_all();
            active_model.update(&connection).await.inspect_err(|e| {
                log::error!("write to db error: {}", e);
            })?;
            Ok(())
        }
    }

    fn reset(&self) -> impl Future<Output = Result<(), RepositoryError>> + Send + 'static {
        log::debug!("Reset Database");
        let connection = self.connection.clone();
        let db_path = self.db_path.clone();
        async move {
            // close db connection
            connection.close().await.inspect_err(|e| {
                log::error!("close db connection error: {}", e);
            })?;
            // remove db file
            if let Some(db_path) = db_path {
                std::fs::remove_file(db_path).inspect_err(|e| {
                    log::error!("remove db file error: {}", e);
                })?;
            }
            Ok(())
        }
    }
}
