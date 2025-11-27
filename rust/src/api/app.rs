use crate::managers::{app_settings::manager::AppSettingsManager, db::DBManager};
use flutter_rust_bridge::PanicBacktrace;
use std::path::Path;

#[flutter_rust_bridge::frb(init)]
pub async fn init_app() {
    std::env::set_var("RUST_BACKTRACE", "1");
    PanicBacktrace::setup();
}

pub async fn init_context(working_dir: String) -> anyhow::Result<Context> {
    // Create working folder if it doesn't exist
    let path = Path::new(&working_dir);
    if !path.exists() {
        std::fs::create_dir(path)?;
    }

    // Data base
    let db_manager = DBManager::new(path).await?;

    // App settings
    let app_settings_manager = AppSettingsManager::new(db_manager).await?;

    Ok(Context {
        app_settings_manager,
    })
}

#[flutter_rust_bridge::frb(opaque)]
pub struct Context {
    pub(crate) app_settings_manager: AppSettingsManager,
}
