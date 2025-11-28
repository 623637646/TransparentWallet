use crate::error::WalletError;
use sea_orm::{ConnectOptions, Database, DatabaseConnection};
use std::path::Path;

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
