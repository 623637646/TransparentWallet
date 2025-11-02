use crate::rx_helper::subscribe_with_callback;
use flutter_rust_bridge::DartFnFuture;
pub use rx_rust::disposable::subscription::Subscription;
use rx_rust::{
    observable::observable_ext::ObservableExt,
    operators::creating::{interval::Interval, just::Just, throw::Throw},
};
use std::{f32::consts::PI, time::Duration};

pub async fn tick(
    name: String,
    callback: impl Fn(Option<usize>, Option<f32>) -> DartFnFuture<()> + Send + 'static,
) -> Subscription<'static> {
    subscribe_with_callback(callback, |runtime| {
        println!("tick {}", name);
        Interval::new(Duration::from_millis(1000), runtime, None)
            .map_infallible_to_error()
            .flat_map(|value| {
                if value < 3 {
                    Just::new(value).map_infallible_to_error().into_boxed()
                } else {
                    Throw::new(PI).map_infallible_to_value().into_boxed()
                }
            })
            .debug("INTERVAL")
    })
}
