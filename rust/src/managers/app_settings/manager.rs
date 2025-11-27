use crate::{
    api_utils::never::Never,
    managers::app_settings::{self, repository::AppSettingsRepository},
};
use futures::FutureExt;
use rx_rust::{
    disposable::subscription::Subscription, observable::observable_ext::ObservableExt,
    subject::behavior_subject::BehaviorSubject,
};

pub(crate) struct AppSettingsManager {
    pub(crate) subject: BehaviorSubject<'static, app_settings::Model, Never>,
    _subscription: Subscription<'static>,
}

impl AppSettingsManager {
    pub(crate) async fn new(
        repository: impl AppSettingsRepository + Send + Sync + 'static,
    ) -> Result<Self, anyhow::Error> {
        let app_settings = repository.get_app_settings().await?;
        let subject = BehaviorSubject::new(app_settings);
        let sub = subject.clone().skip(1).subscribe_with_callback(
            move |value| {
                tokio::spawn(repository.set_app_settings(value).map(|res| {
                    if let Err(e) = res {
                        log::error!("Error setting app settings: {}", e);
                    }
                }));
            },
            |_| unreachable!(),
        );

        Ok(Self {
            subject,
            _subscription: sub,
        })
    }
}
