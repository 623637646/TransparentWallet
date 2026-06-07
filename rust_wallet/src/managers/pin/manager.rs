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

    #[error("Update pin failed, remaining attempts {0}")]
    UpdatePinFailed(u8), // 0 means the secure storage is cleaned.

    #[error("Verify pin when no pin")]
    VerifyPinWhenNoPin,

    #[error("Verify pin failed, remaining attempts {0}")]
    VerifyPinFailed(u8), // 0 means the secure storage is cleaned.
}

const KEY_NAME_DEVICE_SECRET: &str = "hardware_based_device_secret";
const KEY_NAME_NUMBER_OF_PIN_FAILED: &str = "number_of_pin_failed";

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
        let device_secret = self
            .secure_storage
            .read(KEY_NAME_DEVICE_SECRET.to_owned())
            .await?;
        match device_secret {
            Some(device_secret) => Ok(device_secret),
            None => {
                // generate new device secret
                let mut device_secret = [0u8; 32];
                rand::rng().fill_bytes(&mut device_secret);
                let device_secret = device_secret.to_vec();
                self.secure_storage
                    .write(
                        KEY_NAME_DEVICE_SECRET.to_owned(),
                        Some(device_secret.clone()),
                    )
                    .await?;
                Ok(device_secret)
            }
        }
    }

    async fn handle_pin_failed(&self) -> Result<u8, SecureStorageError> {
        const TOTAL_ATTEMPTS: u8 = 3;
        if let Some(Some(number_of_pin_failed)) = self
            .secure_storage
            .read(KEY_NAME_NUMBER_OF_PIN_FAILED.to_owned())
            .await?
            .map(|mut data| data.pop())
        {
            let number_of_pin_failed = number_of_pin_failed + 1;
            if number_of_pin_failed < TOTAL_ATTEMPTS {
                self.secure_storage
                    .write(
                        KEY_NAME_NUMBER_OF_PIN_FAILED.to_owned(),
                        Some(vec![number_of_pin_failed]),
                    )
                    .await?;
                Ok(TOTAL_ATTEMPTS - number_of_pin_failed)
            } else {
                self.secure_storage.clean().await?;
                Ok(0)
            }
        } else {
            self.secure_storage
                .write(KEY_NAME_NUMBER_OF_PIN_FAILED.to_owned(), Some(vec![1]))
                .await?;
            Ok(TOTAL_ATTEMPTS - 1)
        }
    }

    async fn reset_pin_failed_count(&self) -> Result<(), SecureStorageError> {
        self.secure_storage
            .write(KEY_NAME_NUMBER_OF_PIN_FAILED.to_owned(), Some(vec![0]))
            .await
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
        let mut device_secret = self.device_secret().await?;
        let secret_context = SecretContext::new(pin, &device_secret);
        device_secret.zeroize();
        let mut model = self.model.value();
        model.secret_context_data = Some(secret_context.to_bytes());
        self.repository.write::<pin::Entity>(model.clone()).await?;
        self.model.clone().on_next(model);
        Ok(())
    }

    pub async fn delete_pin(&self) -> Result<(), WalletError> {
        if self.secret_context().is_none() {
            return Err(PinError::DeletePinWhenNoPin.into());
        }
        self.reset_pin_failed_count().await?;
        let mut model = self.model.value();
        model.secret_context_data = None;
        self.repository.write::<pin::Entity>(model.clone()).await?;
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
            let remaining_attempts = self.handle_pin_failed().await?;
            return Err(PinError::UpdatePinFailed(remaining_attempts).into());
        }
        device_secret.zeroize();
        self.reset_pin_failed_count().await?;
        let mut model = self.model.value();
        model.secret_context_data = Some(secret_context.to_bytes());
        self.repository.write::<pin::Entity>(model.clone()).await?;
        self.model.clone().on_next(model);
        Ok(())
    }

    pub async fn verify_pin(&self, pin: &[u8]) -> Result<(), WalletError> {
        let Some(secret_context) = self.secret_context() else {
            return Err(PinError::VerifyPinWhenNoPin.into());
        };
        let mut device_secret = self.device_secret().await?;
        let result = secret_context.verify_pin(pin, &device_secret);
        device_secret.zeroize();
        if result {
            self.reset_pin_failed_count().await?;
            Ok(())
        } else {
            let remaining_attempts = self.handle_pin_failed().await?;
            Err(PinError::VerifyPinFailed(remaining_attempts).into())
        }
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

    #[tokio::test]
    async fn new_manager_starts_without_pin() {
        let db = DBManager::new_memory_db().await.unwrap();
        let secure_storage = MockSecureStorage::new();
        let manager = PinManager::new(db, secure_storage).await.unwrap();

        assert!(manager.secret_context().is_none());
        assert!(matches!(
            manager.verify_pin(PIN).await,
            Err(WalletError::PinError(PinError::VerifyPinWhenNoPin))
        ));
    }

    #[tokio::test]
    async fn create_pin_stores_secret_context_and_verifies_pin() {
        let db = DBManager::new_memory_db().await.unwrap();
        let secure_storage = MockSecureStorage::new();
        let manager = PinManager::new(db, secure_storage).await.unwrap();

        manager.create(PIN).await.unwrap();

        assert!(manager.secret_context().is_some());
        assert!(manager.verify_pin(PIN).await.is_ok());
        assert!(manager.verify_pin(WRONG_PIN).await.is_err());
    }

    #[tokio::test]
    async fn create_pin_fails_when_pin_already_exists() {
        let db = DBManager::new_memory_db().await.unwrap();
        let secure_storage = MockSecureStorage::new();
        let manager = PinManager::new(db, secure_storage).await.unwrap();
        manager.create(PIN).await.unwrap();

        let result = manager.create(NEW_PIN).await;

        assert!(matches!(
            result,
            Err(WalletError::PinError(PinError::CreatePinWhenHasPin))
        ));
        assert!(manager.verify_pin(PIN).await.is_ok());
        assert!(manager.verify_pin(NEW_PIN).await.is_err());
    }

    #[tokio::test]
    async fn delete_pin_clears_secret_context() {
        let db = DBManager::new_memory_db().await.unwrap();
        let secure_storage = MockSecureStorage::new();
        let manager = PinManager::new(db, secure_storage).await.unwrap();
        manager.create(PIN).await.unwrap();

        manager.delete_pin().await.unwrap();

        assert!(manager.secret_context().is_none());
        assert!(matches!(
            manager.verify_pin(PIN).await,
            Err(WalletError::PinError(PinError::VerifyPinWhenNoPin))
        ));
    }

    #[tokio::test]
    async fn delete_pin_fails_when_pin_does_not_exist() {
        let db = DBManager::new_memory_db().await.unwrap();
        let secure_storage = MockSecureStorage::new();
        let manager = PinManager::new(db, secure_storage).await.unwrap();

        assert!(matches!(
            manager.delete_pin().await,
            Err(WalletError::PinError(PinError::DeletePinWhenNoPin))
        ));
    }

    #[tokio::test]
    async fn update_pin_replaces_old_pin() {
        let db = DBManager::new_memory_db().await.unwrap();
        let secure_storage = MockSecureStorage::new();
        let manager = PinManager::new(db, secure_storage).await.unwrap();
        manager.create(PIN).await.unwrap();

        manager.update_pin(PIN, NEW_PIN).await.unwrap();

        assert!(manager.verify_pin(PIN).await.is_err());
        assert!(manager.verify_pin(NEW_PIN).await.is_ok());
    }

    #[tokio::test]
    async fn update_pin_fails_when_old_pin_is_wrong() {
        let db = DBManager::new_memory_db().await.unwrap();
        let secure_storage = MockSecureStorage::new();
        let manager = PinManager::new(db, secure_storage).await.unwrap();
        manager.create(PIN).await.unwrap();

        let result = manager.update_pin(WRONG_PIN, NEW_PIN).await;

        assert!(matches!(
            result,
            Err(WalletError::PinError(PinError::UpdatePinFailed(_)))
        ));
        assert!(manager.verify_pin(PIN).await.is_ok());
        assert!(manager.verify_pin(NEW_PIN).await.is_err());
    }

    #[tokio::test]
    async fn update_pin_fails_when_pin_does_not_exist() {
        let db = DBManager::new_memory_db().await.unwrap();
        let secure_storage = MockSecureStorage::new();
        let manager = PinManager::new(db, secure_storage).await.unwrap();

        assert!(matches!(
            manager.update_pin(PIN, NEW_PIN).await,
            Err(WalletError::PinError(PinError::UpdatePinWhenNoPin))
        ));
    }

    #[tokio::test]
    async fn pin_state_is_loaded_from_repository() {
        let db = DBManager::new_memory_db().await.unwrap();
        let secure_storage = MockSecureStorage::new();
        let manager = PinManager::new(db.clone(), secure_storage.clone())
            .await
            .unwrap();
        manager.create(PIN).await.unwrap();

        let reloaded_manager = PinManager::new(db, secure_storage).await.unwrap();

        assert!(reloaded_manager.secret_context().is_some());
        assert!(reloaded_manager.verify_pin(PIN).await.is_ok());
    }

    #[tokio::test]
    async fn create_pin_fails_when_device_secret_cannot_be_persisted() {
        let db = DBManager::new_memory_db().await.unwrap();
        let secure_storage = MockSecureStorage::new_failing(false, true);
        let manager = PinManager::new(db, secure_storage).await.unwrap();

        assert!(matches!(
            manager.create(PIN).await,
            Err(WalletError::SecureStorageError(
                SecureStorageError::WriteFailed(_)
            ))
        ));
        assert!(manager.secret_context().is_none());
    }

    #[tokio::test]
    async fn verify_pin_cleans_secure_storage_after_three_failures() {
        let db = DBManager::new_memory_db().await.unwrap();
        let secure_storage = MockSecureStorage::new();
        let manager = PinManager::new(db, secure_storage.clone()).await.unwrap();
        manager.create(PIN).await.unwrap();

        assert!(
            secure_storage
                .read(KEY_NAME_DEVICE_SECRET.to_owned())
                .await
                .unwrap()
                .is_some()
        );

        // 1st wrong attempt
        assert!(matches!(
            manager.verify_pin(WRONG_PIN).await,
            Err(WalletError::PinError(PinError::VerifyPinFailed(2)))
        ));

        // 2nd wrong attempt
        assert!(matches!(
            manager.verify_pin(WRONG_PIN).await,
            Err(WalletError::PinError(PinError::VerifyPinFailed(1)))
        ));

        // 3rd wrong attempt — secure storage should be cleaned
        assert!(matches!(
            manager.verify_pin(WRONG_PIN).await,
            Err(WalletError::PinError(PinError::VerifyPinFailed(0)))
        ));

        assert!(
            secure_storage
                .read(KEY_NAME_DEVICE_SECRET.to_owned())
                .await
                .unwrap()
                .is_none()
        );
    }

    #[tokio::test]
    async fn verify_pin_resets_failed_count_on_success() {
        let db = DBManager::new_memory_db().await.unwrap();
        let secure_storage = MockSecureStorage::new();
        let manager = PinManager::new(db, secure_storage.clone()).await.unwrap();
        manager.create(PIN).await.unwrap();

        // 1st wrong attempt → remaining attempts = 2
        assert!(matches!(
            manager.verify_pin(WRONG_PIN).await,
            Err(WalletError::PinError(PinError::VerifyPinFailed(2)))
        ));
        assert_eq!(
            secure_storage
                .read(KEY_NAME_NUMBER_OF_PIN_FAILED.to_owned())
                .await
                .unwrap()
                .unwrap(),
            vec![1]
        );

        // Correct pin → resets count to 0
        assert!(manager.verify_pin(PIN).await.is_ok());
        assert_eq!(
            secure_storage
                .read(KEY_NAME_NUMBER_OF_PIN_FAILED.to_owned())
                .await
                .unwrap()
                .unwrap(),
            vec![0]
        );

        // Wrong again → counting restarts from 3
        assert!(matches!(
            manager.verify_pin(WRONG_PIN).await,
            Err(WalletError::PinError(PinError::VerifyPinFailed(2)))
        ));
    }

    #[tokio::test]
    async fn update_pin_failures_increment_failed_count_and_success_resets() {
        let db = DBManager::new_memory_db().await.unwrap();
        let secure_storage = MockSecureStorage::new();
        let manager = PinManager::new(db, secure_storage.clone()).await.unwrap();
        manager.create(PIN).await.unwrap();

        // Update with wrong pin → remaining attempts = 2
        assert!(matches!(
            manager.update_pin(WRONG_PIN, NEW_PIN).await,
            Err(WalletError::PinError(PinError::UpdatePinFailed(2)))
        ));
        assert_eq!(
            secure_storage
                .read(KEY_NAME_NUMBER_OF_PIN_FAILED.to_owned())
                .await
                .unwrap()
                .unwrap(),
            vec![1]
        );

        // Update with correct old pin → resets count to 0
        manager.update_pin(PIN, NEW_PIN).await.unwrap();
        assert_eq!(
            secure_storage
                .read(KEY_NAME_NUMBER_OF_PIN_FAILED.to_owned())
                .await
                .unwrap()
                .unwrap(),
            vec![0]
        );
    }
}
