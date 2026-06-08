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
    let writer = Arc::new(secure_storage_writer);
    let writer = Arc::new(
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
    let reader = Arc::new(secure_storage_reader);
    let reader = Arc::new(
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
    let cleaner = Arc::new(secure_storage_cleaner);
    let cleaner = Arc::new(
        move || -> BoxFuture<'static, Result<(), SecureStorageError>> {
            let cleaner = cleaner.clone();
            Box::pin(async move {
                match cleaner().await {
                    Some(error) => Err(SecureStorageError::CleanFailed(error)),
                    None => Ok(()),
                }
            })
        },
    );
    let wallet_app = WalletApp::builder()
        .working_dir(Path::new(&working_dir))
        .writer(writer)
        .reader(reader)
        .cleaner(cleaner)
        .build()
        .await?;
    let context = Context(wallet_app);
    Ok(context)
}

#[flutter_rust_bridge::frb(opaque)]
pub struct Context(pub(crate) WalletApp);

impl Context {
    pub async fn reset_app(self) -> anyhow::Result<()> {
        self.0.reset_app().await?;
        Ok(())
    }
}
