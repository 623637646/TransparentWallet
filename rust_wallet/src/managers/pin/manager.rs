use crate::{
    error::WalletError,
    managers::{
        db::{DBError, Repository},
        pin,
    },
};
use rust_secret::secret_context::SecretContext;
use rx_rust::{
    observable::{Observable, observable_ext::ObservableExt},
    observer::Observer,
    subject::behavior_subject::BehaviorSubject,
};
use std::convert::Infallible;
use thiserror::Error;

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

pub struct PinManager<R> {
    repository: R,
    model: BehaviorSubject<'static, pin::Model, Infallible>,
}

impl<R> PinManager<R>
where
    R: Repository,
{
    pub(crate) async fn new(repository: R) -> Result<Self, DBError> {
        let model = repository.read::<pin::Entity>().await?;
        let model = BehaviorSubject::new(model);
        Ok(Self { repository, model })
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

    pub fn has_pin(&self) -> impl Observable<'static, 'static, bool, Infallible> {
        self.model
            .clone()
            .map(|model| model.secret_context_data.is_some())
    }

    pub async fn create(&self, pin: &[u8], device_secret: &[u8]) -> Result<(), WalletError> {
        if self.secret_context().is_some() {
            return Err(PinError::CreatePinWhenHasPin.into());
        }
        log::info!("create pin");
        let secret_context = SecretContext::new(pin, device_secret);
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

    pub async fn update_pin(
        &self,
        old_pin: &[u8],
        new_pin: &[u8],
        device_secret: &[u8],
    ) -> Result<(), WalletError> {
        let Some(mut secret_context) = self.secret_context() else {
            return Err(PinError::UpdatePinWhenNoPin.into());
        };
        if !secret_context.update_pin(old_pin, new_pin, device_secret) {
            return Err(PinError::UpdatePinFailed.into());
        }
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

    pub fn verify_pin(&self, pin: &[u8], device_secret: &[u8]) -> Result<bool, PinError> {
        let Some(secret_context) = self.secret_context() else {
            return Err(PinError::VerifyPinWhenNoPin);
        };
        let result = secret_context.verify_pin(pin, device_secret);
        log::info!("verify pin: {}", result);
        Ok(result)
    }
}
