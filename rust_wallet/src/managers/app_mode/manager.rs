use crate::{
    error::WalletError,
    managers::{
        app_mode::{self, AppMode},
        db::Repository,
    },
};
use futures::FutureExt;
use rx_rust::{
    disposable::subscription::Subscription, observable::observable_ext::ObservableExt,
    subject::behavior_subject::BehaviorSubject,
};
use std::convert::Infallible;

pub struct AppModeManager {
    pub current_app_mode: BehaviorSubject<'static, AppMode, Infallible>,
    _subscription: Subscription<'static>,
}

impl AppModeManager {
    pub(crate) async fn new(
        repository: impl Repository + Send + Sync + 'static,
    ) -> Result<Self, WalletError> {
        let model = repository.read::<app_mode::Entity>().await?;
        let current_app_mode = BehaviorSubject::new(model.app_mode.clone());
        let sub = current_app_mode.clone().skip(1).subscribe_with_callback(
            move |value| {
                let mut model = model.clone();
                model.app_mode = value;
                tokio::spawn(repository.write::<app_mode::Entity>(model).map(|res| {
                    if let Err(e) = res {
                        log::error!("set_app_mode error: {}", e);
                    }
                }));
            },
            |_| unreachable!(),
        );

        Ok(Self {
            current_app_mode,
            _subscription: sub,
        })
    }
}
