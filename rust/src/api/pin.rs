use crate::api::context::Context;
use crate::utils::bridge_helper::{subscribe_with_bridge_callback, BridgeSubscription};
use crate::utils::never::BridgeNever;
use flutter_rust_bridge::{frb, DartFnFuture};
pub use rust_wallet::managers::pin::manager::PinAttemptResult;
use rx_rust::observable::observable_ext::ObservableExt;

#[frb(mirror(PinAttemptResult))]
pub enum _PinAttemptResult {
    Success,
    Failed(u8), // remaining attempts, 0 means the app is reset.
}

impl Context {
    pub async fn has_pin_stream(
        &self,
        on_next: impl Fn(bool) -> DartFnFuture<()> + Send + Sync + 'static,
        on_termination: impl Fn(Option<BridgeNever>) -> DartFnFuture<()> + Send + Sync + 'static,
    ) -> BridgeSubscription {
        subscribe_with_bridge_callback(
            |_| self.0.pin_manager.has_pin().map_infallible_to_error(),
            on_next,
            on_termination,
        )
    }

    pub async fn create_pin(&self, pin: &[u8]) -> anyhow::Result<()> {
        self.0.pin_manager.create(pin).await?;
        Ok(())
    }

    pub async fn delete_pin(&self) -> anyhow::Result<()> {
        self.0.pin_manager.delete_pin().await?;
        Ok(())
    }

    pub async fn update_pin(
        &self,
        old_pin: &[u8],
        new_pin: &[u8],
    ) -> anyhow::Result<PinAttemptResult> {
        Ok(self.0.pin_manager.update_pin(old_pin, new_pin).await?)
    }

    pub async fn verify_pin(&self, pin: &[u8]) -> anyhow::Result<PinAttemptResult> {
        Ok(self.0.pin_manager.verify_pin(pin).await?)
    }
}
