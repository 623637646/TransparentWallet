use crate::api::context::Context;
use crate::utils::bridge_helper::{subscribe_with_bridge_callback, BridgeSubscription};
use crate::utils::never::BridgeNever;
use flutter_rust_bridge::{frb, DartFnFuture};
pub use rust_wallet::managers::localization::entities::Language;
use rx_rust::observable::observable_ext::ObservableExt;
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
            || {
                self.wallet_app
                    .localization_manager
                    .language()
                    .map_infallible_to_error()
            },
            on_next,
            on_termination,
        )
    }

    pub async fn set_language(&self, language: Option<Language>) -> anyhow::Result<()> {
        self.wallet_app
            .localization_manager
            .set_language(language)
            .await?;
        Ok(())
    }

    pub async fn set_system_languages(&self, languages: Vec<String>) {
        self.wallet_app
            .localization_manager
            .set_supported_system_languages(languages);
    }

    pub async fn look_up_text(
        &self,
        text_id: String,
        args: Option<HashMap<String, String>>,
        on_next: impl Fn(String) -> DartFnFuture<()> + Send + Sync + 'static,
        on_termination: impl Fn(Option<String>) -> DartFnFuture<()> + Send + Sync + 'static,
    ) -> BridgeSubscription {
        subscribe_with_bridge_callback(
            || {
                self.wallet_app
                    .localization_manager
                    .lookup(text_id, args)
                    .catch(|error| Throw::new(error.to_string()).map_infallible_to_value())
            },
            on_next,
            on_termination,
        )
    }
}
