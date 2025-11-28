use crate::utils::{
    bridge_helper::{subscribe_with_bridge_callback, BridgeSubscription},
    never::BridgeNever,
};
use flutter_rust_bridge::{frb, DartFnFuture};
pub use rust_wallet::logger::{init_logger_observable, LogEntry, LogLevel};
use rx_rust::observable::observable_ext::ObservableExt;

#[frb(mirror(LogEntry))]
pub struct _LogEntry {
    pub time_millis: u128,
    pub level: LogLevel,
    pub tag: String,
    pub msg: String,
}

#[frb(mirror(LogLevel))]
pub enum _LogLevel {
    Trace,
    Debug,
    Info,
    Warn,
    Error,
}

pub async fn init_logger(
    callback: impl Fn(Option<LogEntry>, Option<BridgeNever>) -> DartFnFuture<()> + Send + 'static,
) -> BridgeSubscription {
    subscribe_with_bridge_callback(
        |_| init_logger_observable().map_infallible_to_error(),
        callback,
    )
}
