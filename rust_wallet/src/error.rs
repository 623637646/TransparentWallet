use crate::managers::{db, pin, secure_storage};
use thiserror::Error;

#[derive(Error, Debug)]
pub enum WalletError {
    #[error("Database error: {0}")]
    DBError(#[from] db::RepositoryError),

    #[error("Pin error: {0}")]
    PinError(#[from] pin::manager::PinError),

    #[error("Secure storage error: {0}")]
    SecureStorageError(#[from] secure_storage::SecureStorageError),
}
