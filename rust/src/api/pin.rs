use crate::api::context::Context;
use crate::utils::bridge_helper::{subscribe_with_bridge_callback, BridgeSubscription};
use crate::utils::never::BridgeNever;
use flutter_rust_bridge::DartFnFuture;
use rx_rust::observable::observable_ext::ObservableExt;

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

    pub async fn create_pin(&self, pin: &[u8], device_secret: &[u8]) -> bool {
        self.0.pin_manager.create(pin, device_secret)
    }

    pub async fn delete_pin(&self) -> bool {
        self.0.pin_manager.delete_pin()
    }

    pub async fn update_pin(&self, old_pin: &[u8], new_pin: &[u8], device_secret: &[u8]) -> bool {
        self.0
            .pin_manager
            .update_pin(old_pin, new_pin, device_secret)
    }

    pub async fn verify_pin(&self, pin: &[u8], device_secret: &[u8]) -> bool {
        self.0.pin_manager.verify_pin(pin, device_secret)
    }
}
