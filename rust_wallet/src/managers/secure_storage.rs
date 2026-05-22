use futures::future::BoxFuture;
use thiserror::Error;

#[derive(Error, Debug)]
pub enum SecureStorageError {
    #[error("Read failed: {0}")]
    ReadFailed(String),

    #[error("Write failed: {0}")]
    WriteFailed(String),

    #[error("Clean failed: {0}")]
    CleanFailed(String),
}

pub trait SecureStorage {
    fn write(
        &self,
        key: String,
        data: Option<Vec<u8>>,
    ) -> impl Future<Output = Result<(), SecureStorageError>>;

    fn read(
        &self,
        key: String,
    ) -> impl Future<Output = Result<Option<Vec<u8>>, SecureStorageError>>;

    fn clean(&self) -> impl Future<Output = Result<(), SecureStorageError>>;
}

pub type SecureStorageWriter = Box<
    dyn Fn(String, Option<Vec<u8>>) -> BoxFuture<'static, Result<(), SecureStorageError>>
        + Send
        + Sync,
>;

pub type SecureStorageReader = Box<
    dyn Fn(String) -> BoxFuture<'static, Result<Option<Vec<u8>>, SecureStorageError>> + Send + Sync,
>;

pub type SecureStorageCleaner =
    Box<dyn Fn() -> BoxFuture<'static, Result<(), SecureStorageError>> + Send + Sync>;

pub struct SecureStorageManager {
    writer: SecureStorageWriter,
    reader: SecureStorageReader,
    cleaner: SecureStorageCleaner,
}

impl SecureStorageManager {
    pub fn new(
        writer: SecureStorageWriter,
        reader: SecureStorageReader,
        cleaner: SecureStorageCleaner,
    ) -> Self {
        Self {
            writer,
            reader,
            cleaner,
        }
    }
}

impl SecureStorage for SecureStorageManager {
    async fn write(&self, key: String, data: Option<Vec<u8>>) -> Result<(), SecureStorageError> {
        (self.writer)(key, data).await
    }

    async fn read(&self, key: String) -> Result<Option<Vec<u8>>, SecureStorageError> {
        (self.reader)(key).await
    }

    async fn clean(&self) -> Result<(), SecureStorageError> {
        (self.cleaner)().await
    }
}

#[cfg(test)]
pub(crate) mod mock_secure_storage {
    use super::*;
    use std::{
        collections::HashMap,
        sync::{Arc, RwLock},
    };

    #[derive(Debug, Clone)]
    pub(crate) struct MockSecureStorage {
        data: Arc<RwLock<HashMap<String, Vec<u8>>>>,
        read_failure: bool,
        write_failure: bool,
    }

    impl MockSecureStorage {
        pub(crate) fn new() -> Self {
            Self {
                data: Arc::new(RwLock::new(HashMap::new())),
                read_failure: false,
                write_failure: false,
            }
        }

        pub(crate) fn new_failing(read_failure: bool, write_failure: bool) -> Self {
            Self {
                data: Arc::new(RwLock::new(HashMap::new())),
                read_failure,
                write_failure,
            }
        }
    }

    impl SecureStorage for MockSecureStorage {
        async fn write(
            &self,
            key: String,
            data: Option<Vec<u8>>,
        ) -> Result<(), SecureStorageError> {
            if self.write_failure {
                Err(SecureStorageError::WriteFailed("write denied".to_owned()))
            } else {
                match data {
                    Some(data) => {
                        self.data.write().unwrap().insert(key, data);
                    }
                    None => {
                        self.data.write().unwrap().remove(&key);
                    }
                }
                Ok(())
            }
        }

        async fn read(&self, key: String) -> Result<Option<Vec<u8>>, SecureStorageError> {
            if self.read_failure {
                Err(SecureStorageError::ReadFailed("read denied".to_owned()))
            } else {
                Ok(self.data.read().unwrap().get(&key).cloned())
            }
        }

        async fn clean(&self) -> Result<(), SecureStorageError> {
            self.data.write().unwrap().clear();
            Ok(())
        }
    }
}
