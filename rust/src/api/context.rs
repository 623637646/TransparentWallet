use crate::utils::bridge_helper::{subscribe_with_bridge_callback, BridgeSubscription};
use flutter_rust_bridge::{frb, DartFnFuture, PanicBacktrace};
pub use rust_wallet::logger::{LogEntry, LogLevel};
use rust_wallet::{
    app::WalletApp, logger::get_logger_observable, managers::secure_storage::SecureStorageError,
};
use std::{future::Future, pin::Pin, sync::Arc};

#[flutter_rust_bridge::frb(init)]
pub async fn init_rust() {
    std::env::set_var("RUST_BACKTRACE", "1");
    PanicBacktrace::setup();
}

type BoxFuture<'a, T> = Pin<Box<dyn Future<Output = T> + Send + 'a>>;

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

pub async fn init_context(
    working_dir: String,
    logger: impl Fn(LogEntry) -> DartFnFuture<()> + Send + Sync + 'static,
    secure_storage_writer: impl Fn(String, Option<Vec<u8>>) -> DartFnFuture<Option<String>>
        + Send
        + Sync
        + 'static,
    secure_storage_reader: impl Fn(String) -> DartFnFuture<(Option<Vec<u8>>, Option<String>)>
        + Send
        + Sync
        + 'static,
    secure_storage_cleaner: impl Fn() -> DartFnFuture<Option<String>> + Send + Sync + 'static,
) -> anyhow::Result<Context> {
    // Must init logger first
    let _log_subscription =
        subscribe_with_bridge_callback(get_logger_observable, logger, |_| unreachable!());

    let secure_storage_writer = Arc::new(
        move |key: String,
              data: Option<Vec<u8>>|
              -> BoxFuture<'static, Result<(), SecureStorageError>> {
            let future = secure_storage_writer(key, data);
            Box::pin(async move {
                match future.await {
                    Some(error) => Err(SecureStorageError::WriteFailed(error)),
                    None => Ok(()),
                }
            })
        },
    );
    let secure_storage_reader = Arc::new(
        move |key: String| -> BoxFuture<'static, Result<Option<Vec<u8>>, SecureStorageError>> {
            let future = secure_storage_reader(key);
            Box::pin(async {
                match future.await {
                    (_, Some(error)) => Err(SecureStorageError::ReadFailed(error)),
                    (data, None) => Ok(data),
                }
            })
        },
    );
    let secure_storage_cleaner = Arc::new(
        move || -> BoxFuture<'static, Result<(), SecureStorageError>> {
            let future = secure_storage_cleaner();
            Box::pin(async {
                match future.await {
                    Some(error) => Err(SecureStorageError::CleanFailed(error)),
                    None => Ok(()),
                }
            })
        },
    );

    let wallet_app = WalletApp::builder()
        .working_dir(working_dir.into())
        .secure_storage_writer(secure_storage_writer)
        .secure_storage_reader(secure_storage_reader)
        .secure_storage_cleaner(secure_storage_cleaner)
        .build()
        .await?;

    let context = Context {
        wallet_app,
        _log_subscription,
    };
    Ok(context)
}

#[flutter_rust_bridge::frb(opaque)]
pub struct Context {
    pub(crate) wallet_app: WalletApp,
    _log_subscription: BridgeSubscription,
}

impl Context {
    pub async fn reset_app(&self) -> anyhow::Result<()> {
        self.wallet_app.reset_app().await?;
        Ok(())
    }
}
