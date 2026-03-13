use crate::managers::{db::Repository, pin};
use futures::FutureExt;
use rust_secret::secret_context::SecretContext;
use rx_rust::{
    disposable::subscription::Subscription,
    observable::{Observable, observable_ext::ObservableExt},
    observer::Observer,
    subject::behavior_subject::BehaviorSubject,
};
use sea_orm::DbErr;
use std::convert::Infallible;

pub struct PinManager {
    secret_context: BehaviorSubject<'static, Option<SecretContext>, Infallible>,
    _subscription: Subscription<'static>,
}

impl PinManager {
    pub(crate) async fn new(
        repository: impl Repository + Send + Sync + 'static,
    ) -> Result<Self, DbErr> {
        let model = repository.read::<pin::Entity>().await?;
        let secret_context = model
            .secret_context_data
            .as_ref()
            .map(|secret_context_data| {
                SecretContext::from_bytes(secret_context_data)
                    .expect("secret_context data is valid")
            });
        let secret_context = BehaviorSubject::new(secret_context);
        let sub = secret_context.clone().skip(1).subscribe_with_callback(
            move |value| {
                let mut model = model.clone();
                model.secret_context_data = value.map(|secret_context| secret_context.to_bytes());
                tokio::spawn(repository.write::<pin::Entity>(model).map(|res| {
                    if let Err(e) = res {
                        log::error!("set_secret_context_data error: {}", e);
                    }
                }));
            },
            |_| unreachable!(),
        );

        Ok(Self {
            secret_context,
            _subscription: sub,
        })
    }

    pub fn has_pin(&self) -> impl Observable<'static, 'static, bool, Infallible> {
        self.secret_context
            .clone()
            .map(|secret_context| secret_context.is_some())
    }

    pub fn create(&self, pin: &[u8], device_secret: &[u8]) -> bool {
        if self.secret_context.value().is_some() {
            return false;
        }
        log::info!("create pin");
        let secret_context = SecretContext::new(pin, device_secret);
        self.secret_context.clone().on_next(Some(secret_context));
        true
    }

    pub fn delete_pin(&self) -> bool {
        if self.secret_context.value().is_none() {
            return false;
        }
        log::info!("delete pin");
        self.secret_context.clone().on_next(None);
        true
    }

    pub fn update_pin(&self, old_pin: &[u8], new_pin: &[u8], device_secret: &[u8]) -> bool {
        let Some(mut secret_context) = self.secret_context.value() else {
            return false;
        };
        if !secret_context.update_pin(old_pin, new_pin, device_secret) {
            return false;
        }
        log::info!("update pin");
        self.secret_context.clone().on_next(Some(secret_context));
        true
    }

    pub fn verify_pin(&self, pin: &[u8], device_secret: &[u8]) -> bool {
        let Some(secret_context) = self.secret_context.value() else {
            return false;
        };
        let result = secret_context.verify_pin(pin, device_secret);
        log::info!("verify pin: {}", result);
        result
    }
}
