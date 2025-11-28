use crate::{
    error::WalletError,
    managers::{app_settings::manager::AppSettingsManager, db::DBManager},
};
use std::path::Path;

pub struct WalletApp {
    pub app_settings_manager: AppSettingsManager,
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
        let app_settings_manager = AppSettingsManager::new(db_manager).await?;

        Ok(Self {
            app_settings_manager,
        })
    }
}
