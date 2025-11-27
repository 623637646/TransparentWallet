use crate::{
    api_utils::{
        bridge_helper::{subscribe_with_bridge_callback, BridgeSubscription},
        never::Never,
    },
    utils::logger::{init_logger_observable, LogEntry},
};
use flutter_rust_bridge::DartFnFuture;
use rx_rust::observable::observable_ext::ObservableExt;

pub async fn init_logger(
    callback: impl Fn(Option<LogEntry>, Option<Never>) -> DartFnFuture<()> + Send + 'static,
) -> BridgeSubscription {
    subscribe_with_bridge_callback(
        |_| init_logger_observable().map_infallible_to_error(),
        callback,
    )
}
