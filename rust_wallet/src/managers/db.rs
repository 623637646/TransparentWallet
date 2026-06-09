use rx_rust::{
    disposable::subscription::Subscription,
    observable::{Observable, observable_ext::ObservableExt},
    observer::Observer,
    subject::publish_subject::PublishSubject,
};
use sea_orm::{
    ActiveModelTrait, ConnectOptions, Database, DatabaseConnection, EntityTrait, IntoActiveModel,
    PrimaryKeyTrait,
};
use std::{
    any::type_name_of_val,
    convert::Infallible,
    ops::{Deref, DerefMut},
    path::{Path, PathBuf},
    sync::Arc,
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
    fn read_unique<T>(
        &self,
    ) -> impl Future<Output = Result<T::Model, RepositoryError>> + Send + 'static
    where
        T: EntityTrait,
        T::Model: IntoActiveModel<T::ActiveModel> + Default,
        T::ActiveModel: Send,
        <T::PrimaryKey as PrimaryKeyTrait>::ValueType: From<u8>;

    fn write_unique<T>(
        &self,
        model: T::Model,
    ) -> impl Future<Output = Result<(), RepositoryError>> + Send + 'static
    where
        T: EntityTrait,
        T::Model: IntoActiveModel<T::ActiveModel>,
        T::ActiveModel: Send;

    fn reset(&self) -> impl Future<Output = Result<(), RepositoryError>> + Send + 'static;

    fn reset_notify(&self) -> impl Observable<'static, 'static, (), Infallible>;

    fn reset_default_when_reset_notify<T>(
        &self,
        mut target: impl Observer<T, Infallible> + Send + Sync + 'static,
    ) -> Subscription<'static>
    where
        T: Default + Clone + Send + Sync + 'static,
    {
        let reset_notify = self.reset_notify();
        reset_notify.subscribe_with_callback(
            move |_| {
                target.on_next(T::default());
            },
            |_| {},
        )
    }
}

#[derive(Clone)]
pub struct DBManager {
    connection: Arc<tokio::sync::RwLock<DatabaseConnection>>,
    working_path: Option<PathBuf>,
    reset_notify: PublishSubject<'static, (), Infallible>,
}

const DB_NAME: &str = "wallet.db";

impl DBManager {
    pub(crate) async fn new(working_path: PathBuf) -> Result<Self, RepositoryError> {
        let connection = DBManager::connect_db(Some(&working_path)).await?;
        Ok(Self {
            connection: Arc::new(tokio::sync::RwLock::new(connection)),
            working_path: Some(working_path),
            reset_notify: PublishSubject::new(),
        })
    }

    async fn connect_db(
        working_path: Option<&Path>,
    ) -> Result<DatabaseConnection, RepositoryError> {
        // Create working folder if it doesn't exist
        let db_url = if let Some(working_path) = working_path {
            if !working_path.exists() {
                std::fs::create_dir(working_path)?;
            }

            let db_path = working_path.join(DB_NAME);
            let db_url = format!("sqlite://{}?mode=rwc", db_path.to_str().unwrap());
            db_url
        } else {
            "sqlite::memory:".to_owned()
        };

        let mut opt = ConnectOptions::new(db_url);
        opt.sqlx_logging(false);

        let connection = Database::connect(opt).await?;

        // Register schema
        connection
            .get_schema_registry(module_path!().split("::").next().unwrap())
            .sync(&connection)
            .await?;

        Ok(connection)
    }

    #[cfg(test)]
    pub(crate) async fn new_memory_db() -> Result<Self, RepositoryError> {
        let connection = DBManager::connect_db(None).await?;
        Ok(Self {
            connection: Arc::new(tokio::sync::RwLock::new(connection)),
            working_path: None,
            reset_notify: PublishSubject::new(),
        })
    }
}

impl Repository for DBManager {
    fn read_unique<T>(
        &self,
    ) -> impl Future<Output = Result<T::Model, RepositoryError>> + Send + 'static
    where
        T: EntityTrait,
        T::Model: IntoActiveModel<T::ActiveModel> + Default,
        T::ActiveModel: Send,
        <T::PrimaryKey as PrimaryKeyTrait>::ValueType: From<u8>,
    {
        let connection = self.connection.clone();
        async move {
            match T::find_by_id(0)
                .one(connection.read().await.deref())
                .await
                .inspect_err(|e| {
                    log::error!("read from db error: {}", e);
                })? {
                Some(model) => Ok(model),
                None => Ok(T::Model::default()),
            }
        }
    }

    fn write_unique<T>(
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

            // 1. Try updating the record first (assumes it exists)
            match active_model
                .clone()
                .update(connection.read().await.deref())
                .await
            {
                Ok(_) => Ok(()),
                // 2. If it fails because the row does not exist, insert it
                Err(sea_orm::DbErr::RecordNotUpdated) => {
                    active_model
                        .insert(connection.read().await.deref())
                        .await
                        .inspect_err(|e| {
                            log::error!("insert to db error: {}", e);
                        })?;
                    Ok(())
                }
                Err(e) => {
                    log::error!("update to db error: {}", e);
                    Err(RepositoryError::DBError(e))
                }
            }
        }
    }

    fn reset(&self) -> impl Future<Output = Result<(), RepositoryError>> + Send + 'static {
        log::debug!("Reset Database");
        let connection = self.connection.clone();
        let working_path = self.working_path.clone();
        let mut reset_notify = self.reset_notify.clone();
        async move {
            let mut lock = connection.write().await;
            let connection = lock.deref_mut();

            // close db connection
            connection.clone().close().await.inspect_err(|e| {
                log::error!("close db connection error: {}", e);
            })?;

            // remove db file
            if let Some(working_path) = &working_path {
                tokio::fs::remove_file(working_path.join(DB_NAME))
                    .await
                    .inspect_err(|e| {
                        log::error!("remove db file error: {}", e);
                    })?;
            }

            // reconnect
            *connection = DBManager::connect_db(working_path.as_deref()).await?;

            // drop lock
            drop(lock);

            // run reset callbacks
            reset_notify.on_next(());
            Ok(())
        }
    }

    fn reset_notify(&self) -> impl Observable<'static, 'static, (), Infallible> {
        self.reset_notify.clone()
    }
}
