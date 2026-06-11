use crate::{
    error::WalletError,
    managers::{
        app_mode::manager::AppModeManager,
        db::{DBManager, Repository},
        localization::manager::LocalizationManager,
        pin::manager::PinManager,
        secure_storage::{
            SecureStorage, SecureStorageCleaner, SecureStorageManager, SecureStorageReader,
            SecureStorageWriter,
        },
    },
};
use bon::bon;
use rx_rust::{disposable::subscription::Subscription, observable::observable_ext::ObservableExt};
use std::path::PathBuf;

pub struct WalletApp {
    db_manager: DBManager,
    secure_storage_manager: SecureStorageManager,
    pub app_mode_manager: AppModeManager<DBManager>,
    pub localization_manager: LocalizationManager<DBManager>,
    pub pin_manager: PinManager<DBManager, SecureStorageManager>,
    _subscription: Subscription<'static>,
}

#[bon]
impl WalletApp {
    #[builder]
    pub async fn new(
        working_dir: PathBuf,
        secure_storage_writer: SecureStorageWriter,
        secure_storage_reader: SecureStorageReader,
        secure_storage_cleaner: SecureStorageCleaner,
    ) -> Result<Self, WalletError> {
        // Data base
        let db_manager = DBManager::new(working_dir).await?;

        // Secure storage
        let secure_storage_manager = SecureStorageManager::new(
            secure_storage_writer,
            secure_storage_reader,
            secure_storage_cleaner,
        );

        // App settings
        let app_mode_manager = AppModeManager::new(db_manager.clone()).await?;

        // Localization
        let localization_manager = LocalizationManager::new(db_manager.clone()).await?;

        // Pin
        let pin_manager =
            PinManager::new(db_manager.clone(), secure_storage_manager.clone()).await?;

        // Subscribe to pin reset signal: when PIN attempts are exhausted, perform a full app reset
        let db_manager_cloned = db_manager.clone();
        let secure_storage_manager_cloned = secure_storage_manager.clone();
        let _subscription = pin_manager.app_reset_required().subscribe_with_callback(
            move |_| {
                let db = db_manager_cloned.clone();
                let storage = secure_storage_manager_cloned.clone();
                tokio::spawn(async move {
                    do_reset_app(&storage, &db).await.unwrap();
                });
            },
            |_| {},
        );

        Ok(Self {
            db_manager,
            secure_storage_manager,
            app_mode_manager,
            localization_manager,
            pin_manager,
            _subscription,
        })
    }

    pub async fn reset_app(&self) -> Result<(), WalletError> {
        do_reset_app(&self.secure_storage_manager, &self.db_manager).await
    }
}

async fn do_reset_app(storage: &SecureStorageManager, db: &DBManager) -> Result<(), WalletError> {
    storage.clean().await?;
    db.reset().await?;
    Ok(())
}
