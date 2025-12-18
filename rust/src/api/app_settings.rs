use crate::api::context::Context;
use crate::utils::bridge_helper::{subscribe_with_bridge_callback, BridgeSubscription};
use crate::utils::never::BridgeNever;
use flutter_rust_bridge::{frb, DartFnFuture};
pub use rust_wallet::managers::app_settings::entities::{AppMode, Language};
use rx_rust::observable::observable_ext::ObservableExt;
use rx_rust::observer::Observer;

#[frb(mirror(AppMode))]
pub enum _AppMode {
    Init,
    ColdWallet,
    HotWallet,
}

#[frb(mirror(Language))]
pub enum _Language {
    English,
    Chinese,
}

impl Context {
    pub async fn app_mode_stream(
        &self,
        on_next: impl Fn(AppMode) -> DartFnFuture<()> + Send + Sync + 'static,
        on_termination: impl Fn(Option<BridgeNever>) -> DartFnFuture<()> + Send + Sync + 'static,
    ) -> BridgeSubscription {
        subscribe_with_bridge_callback(
            |_| {
                self.0
                    .app_settings_manager
                    .subject
                    .clone()
                    .map(|e| e.app_mode)
                    .map_infallible_to_error()
            },
            on_next,
            on_termination,
        )
    }

    pub async fn set_app_mode(&mut self, app_mode: AppMode) {
        let mut app_settings = self.0.app_settings_manager.subject.value();
        app_settings.app_mode = app_mode;
        self.0.app_settings_manager.subject.on_next(app_settings);
    }

    pub async fn language_stream(
        &self,
        on_next: impl Fn(Language) -> DartFnFuture<()> + Send + Sync + 'static,
        on_termination: impl Fn(Option<BridgeNever>) -> DartFnFuture<()> + Send + Sync + 'static,
    ) -> BridgeSubscription {
        subscribe_with_bridge_callback(
            |_| {
                self.0
                    .app_settings_manager
                    .subject
                    .clone()
                    .map(|e| e.language)
                    .map_infallible_to_error()
            },
            on_next,
            on_termination,
        )
    }

    pub async fn set_language(&mut self, language: Language) {
        let mut app_settings = self.0.app_settings_manager.subject.value();
        app_settings.language = language;
        self.0.app_settings_manager.subject.on_next(app_settings);
    }
}
