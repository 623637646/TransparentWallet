use crate::api::context::Context;
use crate::utils::bridge_helper::{subscribe_with_bridge_callback, BridgeSubscription};
use crate::utils::never::BridgeNever;
use flutter_rust_bridge::{frb, DartFnFuture};
pub use rust_wallet::managers::app_mode::entities::AppMode;
use rx_rust::observable::observable_ext::ObservableExt;
use rx_rust::observer::Observer;

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
            |_| {
                self.0
                    .app_mode_manager
                    .current_app_mode
                    .clone()
                    .map_infallible_to_error()
            },
            on_next,
            on_termination,
        )
    }

    pub async fn set_app_mode(&mut self, app_mode: AppMode) {
        self.0.app_mode_manager.current_app_mode.on_next(app_mode);
    }
}
