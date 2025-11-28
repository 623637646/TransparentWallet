use flutter_rust_bridge::PanicBacktrace;
use rust_wallet::app::WalletApp;
use std::path::Path;

#[flutter_rust_bridge::frb(init)]
pub async fn init_rust() {
    std::env::set_var("RUST_BACKTRACE", "1");
    PanicBacktrace::setup();
}

pub async fn init_context(working_dir: String) -> anyhow::Result<Context> {
    Ok(Context(WalletApp::new(Path::new(&working_dir)).await?))
}

#[flutter_rust_bridge::frb(opaque)]
pub struct Context(pub(crate) WalletApp);
