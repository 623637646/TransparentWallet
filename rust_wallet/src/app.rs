use crate::{
    error::WalletError,
    managers::{
        app_mode::manager::AppModeManager,
        db::DBManager,
        localization::manager::LocalizationManager,
        pin::manager::PinManager,
        secure_storage::{
            SecureStorageCleaner, SecureStorageManager, SecureStorageReader, SecureStorageWriter,
        },
    },
};
use std::path::Path;

pub struct WalletApp {
    pub app_mode_manager: AppModeManager<DBManager>,
    pub localization_manager: LocalizationManager<DBManager>,
    pub pin_manager: PinManager<DBManager, SecureStorageManager>,
}

impl WalletApp {
    pub async fn new(
        working_dir: &Path,
        writer: SecureStorageWriter,
        reader: SecureStorageReader,
        cleaner: SecureStorageCleaner,
    ) -> Result<Self, WalletError> {
        // Data base
        let db_manager = DBManager::new(working_dir).await?;

        // Secure storage
        let secure_storage_manager = SecureStorageManager::new(writer, reader, cleaner);

        // App settings
        let app_mode_manager = AppModeManager::new(db_manager.clone()).await?;

        // Localization
        let localization_manager = LocalizationManager::new(db_manager.clone()).await?;

        // Pin
        let pin_manager = PinManager::new(db_manager.clone(), secure_storage_manager).await?;

        Ok(Self {
            app_mode_manager,
            localization_manager,
            pin_manager,
        })
    }
}
