use flutter_rust_bridge::{DartFnFuture, PanicBacktrace};
use rust_wallet::{app::WalletApp, managers::secure_storage::SecureStorageError};
use std::{future::Future, path::Path, pin::Pin, sync::Arc};

#[flutter_rust_bridge::frb(init)]
pub async fn init_rust() {
    std::env::set_var("RUST_BACKTRACE", "1");
    PanicBacktrace::setup();
}

type BoxFuture<'a, T> = Pin<Box<dyn Future<Output = T> + Send + 'a>>;

pub async fn init_context(
    working_dir: String,
    writer: impl Fn(String, Option<Vec<u8>>) -> DartFnFuture<Option<String>> + Send + Sync + 'static,
    reader: impl Fn(String) -> DartFnFuture<(Option<Vec<u8>>, Option<String>)> + Send + Sync + 'static,
) -> anyhow::Result<Context> {
    let writer = Arc::new(writer);
    let writer = Box::new(
        move |key: String,
              data: Option<Vec<u8>>|
              -> BoxFuture<'static, Result<(), SecureStorageError>> {
            let writer = writer.clone();
            Box::pin(async move {
                match writer(key, data).await {
                    Some(error) => Err(SecureStorageError::WriteFailed(error)),
                    None => Ok(()),
                }
            })
        },
    );
    let reader = Arc::new(reader);
    let reader = Box::new(
        move |key: String| -> BoxFuture<'static, Result<Option<Vec<u8>>, SecureStorageError>> {
            let reader = reader.clone();
            Box::pin(async move {
                match reader(key).await {
                    (_, Some(error)) => Err(SecureStorageError::ReadFailed(error)),
                    (data, None) => Ok(data),
                }
            })
        },
    );
    let walet_app = WalletApp::new(Path::new(&working_dir), writer, reader).await?;
    let context = Context(walet_app);
    Ok(context)
}

#[flutter_rust_bridge::frb(opaque)]
pub struct Context(pub(crate) WalletApp);
