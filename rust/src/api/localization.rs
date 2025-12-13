use crate::api::context::Context;
use crate::utils::bridge_helper::{subscribe_with_bridge_callback, BridgeSubscription};
use crate::utils::never::BridgeNever;
use flutter_rust_bridge::{frb, DartFnFuture};
pub use rust_wallet::managers::localization::entities::Language;
use rx_rust::observable::observable_ext::ObservableExt;
use rx_rust::observer::Observer;
use rx_rust::operators::creating::throw::Throw;
use std::collections::HashMap;

#[frb(mirror(Language))]
pub enum _Language {
    English,
    Chinese,
}

impl Context {
    pub async fn language_stream(
        &self,
        on_next: impl Fn(Option<Language>) -> DartFnFuture<()> + Send + Sync + 'static,
        on_termination: impl Fn(Option<BridgeNever>) -> DartFnFuture<()> + Send + Sync + 'static,
    ) -> BridgeSubscription {
        subscribe_with_bridge_callback(
            |_| {
                self.0
                    .localization_manager
                    .selected_language
                    .clone()
                    .map_infallible_to_error()
            },
            on_next,
            on_termination,
        )
    }

    pub async fn set_language(&mut self, language: Option<Language>) {
        self.0
            .localization_manager
            .selected_language
            .on_next(language);
    }

    pub async fn set_system_languages(&mut self, languages: Vec<String>) {
        self.0
            .localization_manager
            .update_system_language(languages);
    }

    pub async fn lookup_local(
        &self,
        text_id: String,
        on_next: impl Fn(String) -> DartFnFuture<()> + Send + Sync + 'static,
        on_termination: impl Fn(Option<String>) -> DartFnFuture<()> + Send + Sync + 'static,
    ) -> BridgeSubscription {
        subscribe_with_bridge_callback(
            |_| {
                self.0
                    .localization_manager
                    .lookup(text_id)
                    .catch(|error| Throw::new(error.to_string()).map_infallible_to_value())
            },
            on_next,
            on_termination,
        )
    }

    pub async fn lookup_local_with_args(
        &self,
        text_id: String,
        args: HashMap<String, String>,
        on_next: impl Fn(String) -> DartFnFuture<()> + Send + Sync + 'static,
        on_termination: impl Fn(Option<String>) -> DartFnFuture<()> + Send + Sync + 'static,
    ) -> BridgeSubscription {
        subscribe_with_bridge_callback(
            |_| {
                self.0
                    .localization_manager
                    .lookup_with_args(text_id, args)
                    .catch(|error| Throw::new(error.to_string()).map_infallible_to_value())
            },
            on_next,
            on_termination,
        )
    }
}
