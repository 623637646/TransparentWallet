use crate::api::app::Context;
use crate::api_utils::bridge_helper::{subscribe_with_bridge_callback, BridgeSubscription};
use crate::api_utils::never::Never;
use crate::managers::app_settings::{AppMode, Language};
use flutter_rust_bridge::DartFnFuture;
use rx_rust::observable::observable_ext::ObservableExt;
use rx_rust::observer::Observer;

impl Context {
    pub async fn app_mode_stream(
        &self,
        callback: impl Fn(Option<AppMode>, Option<Never>) -> DartFnFuture<()> + Send + 'static,
    ) -> BridgeSubscription {
        subscribe_with_bridge_callback(
            |_| {
                self.app_settings_manager
                    .subject
                    .clone()
                    .map(|e| e.app_mode)
            },
            callback,
        )
    }

    pub async fn set_app_mode(&mut self, app_mode: AppMode) {
        let mut app_settings = self.app_settings_manager.subject.value();
        app_settings.app_mode = app_mode;
        self.app_settings_manager.subject.on_next(app_settings);
    }

    pub async fn language_stream(
        &self,
        callback: impl Fn(Option<Language>, Option<Never>) -> DartFnFuture<()> + Send + 'static,
    ) -> BridgeSubscription {
        subscribe_with_bridge_callback(
            |_| {
                self.app_settings_manager
                    .subject
                    .clone()
                    .map(|e| e.language)
            },
            callback,
        )
    }

    pub async fn set_language(&mut self, language: Language) {
        let mut app_settings = self.app_settings_manager.subject.value();
        app_settings.language = language;
        self.app_settings_manager.subject.on_next(app_settings);
    }
}
