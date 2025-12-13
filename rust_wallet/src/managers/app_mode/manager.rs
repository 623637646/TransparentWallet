use crate::{
    error::WalletError,
    managers::app_mode::{AppMode, repository::AppModeRepository},
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
        repository: impl AppModeRepository + Send + Sync + 'static,
    ) -> Result<Self, WalletError> {
        let app_mode = repository.get_app_mode().await?;
        let current_app_mode = BehaviorSubject::new(app_mode.app_mode.clone());
        let sub = current_app_mode.clone().skip(1).subscribe_with_callback(
            move |value| {
                let mut app_mode = app_mode.clone();
                app_mode.app_mode = value;
                tokio::spawn(repository.set_app_mode(app_mode).map(|res| {
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
