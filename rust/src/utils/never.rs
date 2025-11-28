use flutter_rust_bridge::frb;
use std::convert::Infallible;

// TODO: Use Infallible instead of this `Never` after this issue is fixed: https://github.com/fzyzcjy/flutter_rust_bridge/issues/2920
#[frb(opaque)]
#[derive(Debug, Clone, PartialEq, Eq)]
pub(crate) struct BridgeNever(Infallible);
