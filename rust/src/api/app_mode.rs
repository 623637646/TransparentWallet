use crate::api::context::Context;
use crate::utils::bridge_helper::{subscribe_with_bridge_callback, BridgeSubscription};
use crate::utils::never::BridgeNever;
use flutter_rust_bridge::{frb, DartFnFuture};
pub use rust_wallet::managers::app_mode::entities::AppMode;
use rx_rust::observable::observable_ext::ObservableExt;

#[frb(mirror(AppMode))]
pub enum _AppMode {
    Init,
    ColdWallet,
    HotWallet,
}

impl Context {
    pub async fn app_mode_stream(
        &self,
        on_next: impl Fn(AppMode) -> DartFnFuture<()> + Send + Sync + 'static,
        on_termination: impl Fn(Option<BridgeNever>) -> DartFnFuture<()> + Send + Sync + 'static,
    ) -> BridgeSubscription {
        subscribe_with_bridge_callback(
            || self.0.app_mode_manager.app_mode().map_infallible_to_error(),
            on_next,
            on_termination,
        )
    }

    pub async fn set_app_mode(&self, app_mode: AppMode) {
        _ = self.0.app_mode_manager.set_app_mode(app_mode).await;
    }
}
