use crate::{
    error::WalletError,
    managers::{
        db::{Repository, RepositoryError},
        pin,
        secure_storage::{SecureStorage, SecureStorageError},
    },
};
use rand::Rng;
use rust_secret::secret_context::SecretContext;
use rx_rust::{
    observable::{Observable, observable_ext::ObservableExt},
    observer::Observer,
    subject::behavior_subject::BehaviorSubject,
};
use std::convert::Infallible;
use thiserror::Error;
use zeroize::Zeroize;

#[derive(Error, Debug)]
pub enum PinError {
    #[error("Create pin when has pin")]
    CreatePinWhenHasPin,

    #[error("Delete pin when no pin")]
    DeletePinWhenNoPin,

    #[error("Update pin when no pin")]
    UpdatePinWhenNoPin,

    #[error("Update pin failed")]
    UpdatePinFailed,

    #[error("Verify pin when no pin")]
    VerifyPinWhenNoPin,
}

pub struct PinManager<R, S> {
    repository: R,
    secure_storage: S,
    model: BehaviorSubject<'static, pin::Model, Infallible>,
}

impl<R, S> PinManager<R, S>
where
    R: Repository,
    S: SecureStorage,
{
    pub(crate) async fn new(repository: R, secure_storage: S) -> Result<Self, RepositoryError> {
        let model = repository.read::<pin::Entity>().await?;
        let model = BehaviorSubject::new(model);
        Ok(Self {
            repository,
            secure_storage,
            model,
        })
    }

    fn secret_context(&self) -> Option<SecretContext> {
        self.model
            .value()
            .secret_context_data
            .as_ref()
            .map(|secret_context_data| {
                SecretContext::from_bytes(secret_context_data)
                    .expect("secret_context data is valid")
            })
    }

    async fn device_secret(&self) -> Result<Vec<u8>, SecureStorageError> {
        const KEY_NAME: &str = "hardware_based_device_secret";
        let device_secret = self.secure_storage.read(KEY_NAME.to_owned()).await?;
        match device_secret {
            Some(device_secret) => Ok(device_secret),
            None => {
                // generate new device secret
                let mut device_secret = [0u8; 32];
                rand::rng().fill_bytes(&mut device_secret);
                let device_secret = device_secret.to_vec();
                self.secure_storage
                    .write(KEY_NAME.to_owned(), Some(device_secret.clone()))
                    .await?;
                Ok(device_secret)
            }
        }
    }

    pub fn has_pin(&self) -> impl Observable<'static, 'static, bool, Infallible> {
        self.model
            .clone()
            .map(|model| model.secret_context_data.is_some())
    }

    pub async fn create(&self, pin: &[u8]) -> Result<(), WalletError> {
        if self.secret_context().is_some() {
            return Err(PinError::CreatePinWhenHasPin.into());
        }
        log::info!("create pin");
        let mut device_secret = self.device_secret().await?;
        let secret_context = SecretContext::new(pin, &device_secret);
        device_secret.zeroize();
        let mut model = self.model.value();
        model.secret_context_data = Some(secret_context.to_bytes());
        self.repository
            .write::<pin::Entity>(model.clone())
            .await
            .inspect_err(|e| {
                log::error!("write pin error: {}", e);
            })?;
        self.model.clone().on_next(model);
        Ok(())
    }

    pub async fn delete_pin(&self) -> Result<(), WalletError> {
        if self.secret_context().is_none() {
            return Err(PinError::DeletePinWhenNoPin.into());
        }
        log::info!("delete pin");
        let mut model = self.model.value();
        model.secret_context_data = None;
        self.repository
            .write::<pin::Entity>(model.clone())
            .await
            .inspect_err(|e| {
                log::error!("write pin error: {}", e);
            })?;
        self.model.clone().on_next(model);
        Ok(())
    }

    pub async fn update_pin(&self, old_pin: &[u8], new_pin: &[u8]) -> Result<(), WalletError> {
        let Some(mut secret_context) = self.secret_context() else {
            return Err(PinError::UpdatePinWhenNoPin.into());
        };
        let mut device_secret = self.device_secret().await?;
        if !secret_context.update_pin(old_pin, new_pin, &device_secret) {
            device_secret.zeroize();
            return Err(PinError::UpdatePinFailed.into());
        }
        device_secret.zeroize();
        log::info!("update pin");
        let mut model = self.model.value();
        model.secret_context_data = Some(secret_context.to_bytes());
        self.repository
            .write::<pin::Entity>(model.clone())
            .await
            .inspect_err(|e| {
                log::error!("write pin error: {}", e);
            })?;
        self.model.clone().on_next(model);
        Ok(())
    }

    pub async fn verify_pin(&self, pin: &[u8]) -> Result<bool, WalletError> {
        let Some(secret_context) = self.secret_context() else {
            return Err(PinError::VerifyPinWhenNoPin.into());
        };
        let mut device_secret = self.device_secret().await?;
        let result = secret_context.verify_pin(pin, &device_secret);
        device_secret.zeroize();
        log::info!("verify pin: {}", result);
        Ok(result)
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::managers::{
        db::DBManager,
        secure_storage::{SecureStorageError, mock_secure_storage::MockSecureStorage},
    };

    const PIN: &[u8] = b"123456";
    const NEW_PIN: &[u8] = b"654321";
    const WRONG_PIN: &[u8] = b"111111";

    async fn new_manager() -> PinManager<DBManager, MockSecureStorage> {
        let db = DBManager::new_memory_db()
            .await
            .expect("memory db should be created");
        let secure_storage = MockSecureStorage::new();
        PinManager::new(db, secure_storage)
            .await
            .expect("pin manager should be created")
    }

    async fn assert_verify_pin(
        manager: &PinManager<DBManager, MockSecureStorage>,
        pin: &[u8],
        expected: bool,
    ) {
        assert_eq!(
            manager
                .verify_pin(pin)
                .await
                .expect("pin verification should return a bool"),
            expected
        );
    }

    #[tokio::test]
    async fn new_manager_starts_without_pin() {
        let manager = new_manager().await;

        assert!(manager.secret_context().is_none());
        assert!(matches!(
            manager.verify_pin(PIN).await,
            Err(WalletError::PinError(PinError::VerifyPinWhenNoPin))
        ));
    }

    #[tokio::test]
    async fn create_pin_stores_secret_context_and_verifies_pin() {
        let manager = new_manager().await;

        manager
            .create(PIN)
            .await
            .expect("create pin should succeed");

        assert!(manager.secret_context().is_some());
        assert_verify_pin(&manager, PIN, true).await;
        assert_verify_pin(&manager, WRONG_PIN, false).await;
    }

    #[tokio::test]
    async fn create_pin_fails_when_pin_already_exists() {
        let manager = new_manager().await;
        manager
            .create(PIN)
            .await
            .expect("initial create pin should succeed");

        let result = manager.create(NEW_PIN).await;

        assert!(matches!(
            result,
            Err(WalletError::PinError(PinError::CreatePinWhenHasPin))
        ));
        assert_verify_pin(&manager, PIN, true).await;
        assert_verify_pin(&manager, NEW_PIN, false).await;
    }

    #[tokio::test]
    async fn delete_pin_clears_secret_context() {
        let manager = new_manager().await;
        manager
            .create(PIN)
            .await
            .expect("create pin should succeed");

        manager
            .delete_pin()
            .await
            .expect("delete pin should succeed");

        assert!(manager.secret_context().is_none());
        assert!(matches!(
            manager.verify_pin(PIN).await,
            Err(WalletError::PinError(PinError::VerifyPinWhenNoPin))
        ));
    }

    #[tokio::test]
    async fn delete_pin_fails_when_pin_does_not_exist() {
        let manager = new_manager().await;

        let result = manager.delete_pin().await;

        assert!(matches!(
            result,
            Err(WalletError::PinError(PinError::DeletePinWhenNoPin))
        ));
    }

    #[tokio::test]
    async fn update_pin_replaces_old_pin() {
        let manager = new_manager().await;
        manager
            .create(PIN)
            .await
            .expect("create pin should succeed");

        manager
            .update_pin(PIN, NEW_PIN)
            .await
            .expect("update pin should succeed");

        assert_verify_pin(&manager, PIN, false).await;
        assert_verify_pin(&manager, NEW_PIN, true).await;
    }

    #[tokio::test]
    async fn update_pin_fails_when_old_pin_is_wrong() {
        let manager = new_manager().await;
        manager
            .create(PIN)
            .await
            .expect("create pin should succeed");

        let result = manager.update_pin(WRONG_PIN, NEW_PIN).await;

        assert!(matches!(
            result,
            Err(WalletError::PinError(PinError::UpdatePinFailed))
        ));
        assert_verify_pin(&manager, PIN, true).await;
        assert_verify_pin(&manager, NEW_PIN, false).await;
    }

    #[tokio::test]
    async fn update_pin_fails_when_pin_does_not_exist() {
        let manager = new_manager().await;

        let result = manager.update_pin(PIN, NEW_PIN).await;

        assert!(matches!(
            result,
            Err(WalletError::PinError(PinError::UpdatePinWhenNoPin))
        ));
    }

    #[tokio::test]
    async fn pin_state_is_loaded_from_repository() {
        let db = DBManager::new_memory_db()
            .await
            .expect("memory db should be created");
        let secure_storage = MockSecureStorage::new();
        let manager = PinManager::new(db.clone(), secure_storage.clone())
            .await
            .expect("pin manager should be created");
        manager
            .create(PIN)
            .await
            .expect("create pin should succeed");

        let reloaded_manager = PinManager::new(db, secure_storage)
            .await
            .expect("pin manager should be reloaded");

        assert!(reloaded_manager.secret_context().is_some());
        assert_verify_pin(&reloaded_manager, PIN, true).await;
    }

    #[tokio::test]
    async fn create_pin_fails_when_device_secret_cannot_be_persisted() {
        let db = DBManager::new_memory_db()
            .await
            .expect("memory db should be created");
        let secure_storage = MockSecureStorage::new_failing(false, true);
        let manager = PinManager::new(db, secure_storage)
            .await
            .expect("pin manager should be created");

        let result = manager.create(PIN).await;

        assert!(matches!(
            result,
            Err(WalletError::SecureStorageError(
                SecureStorageError::WriteFailed(_)
            ))
        ));
        assert!(manager.secret_context().is_none());
    }
}
