use crate::managers::{db, pin};
use thiserror::Error;

#[derive(Error, Debug)]
pub enum WalletError {
    #[error("IO error: {0}")]
    IOError(#[from] std::io::Error),

    #[error("Database error: {0}")]
    DBError(#[from] db::DBError),

    #[error("Pin error: {0}")]
    PinError(#[from] pin::manager::PinError),
}
