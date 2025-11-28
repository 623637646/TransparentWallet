use thiserror::Error;

#[derive(Error, Debug)]
pub enum WalletError {
    #[error("IO error: {0}")]
    IOError(#[from] std::io::Error),

    #[error("Database error: {0}")]
    DBError(#[from] sea_orm::DbErr),
}
