use crate::{
    error::WalletError,
    managers::{
        app_mode::manager::AppModeManager, db::DBManager,
        localization::manager::LocalizationManager, pin::manager::PinManager,
    },
};
use std::path::Path;

pub struct WalletApp {
    pub app_mode_manager: AppModeManager,
    pub localization_manager: LocalizationManager,
    pub pin_manager: PinManager,
}

impl WalletApp {
    pub async fn new(working_dir: &Path) -> Result<Self, WalletError> {
        // Create working folder if it doesn't exist
        if !working_dir.exists() {
            std::fs::create_dir(working_dir)?;
        }

        // Data base
        let db_manager = DBManager::new(working_dir).await?;

        // App settings
        let app_mode_manager = AppModeManager::new(db_manager.clone()).await?;

        // Localization
        let localization_manager = LocalizationManager::new(db_manager.clone()).await?;

        // Pin
        let pin_manager = PinManager::new(db_manager.clone()).await?;

        Ok(Self {
            app_mode_manager,
            localization_manager,
            pin_manager,
        })
    }
}
