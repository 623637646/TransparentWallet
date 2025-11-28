use flutter_rust_bridge::{frb, DartFnFuture};
use rx_rust::{
    disposable::subscription::Subscription,
    observable::{observable_ext::ObservableExt, Observable},
    observer::Termination,
};
use std::sync::Arc;
use tokio::{runtime::Handle, sync::Mutex};

#[frb(opaque)]
pub struct BridgeSubscription {
    _sub: Subscription<'static>,
}

pub(crate) fn subscribe_with_bridge_callback<T, E, OE>(
    observable_builder: impl FnOnce(Handle) -> OE,
    callback: impl Fn(Option<T>, Option<E>) -> DartFnFuture<()> + Send + 'static,
) -> BridgeSubscription
where
    T: Send + Sync + 'static,
    E: Send + Sync + 'static,
    OE: Observable<'static, 'static, T, E>,
{
    let runtime = tokio::runtime::Handle::current();
    let runtime_cloned = runtime.clone();
    let callback = Arc::new(Mutex::new(callback));
    let callback_cloned = callback.clone();

    let observable = observable_builder(runtime.clone());
    let sub = observable.on_backpressure_buffer().subscribe_with_callback(
        move |(values, request)| {
            let callback = callback.clone();
            runtime.spawn(async move {
                let callback = callback.lock().await;
                for value in values {
                    callback(Some(value), None).await;
                }
                request();
            });
        },
        move |termination| {
            runtime_cloned.spawn(async move {
                callback_cloned.lock().await(
                    None,
                    match termination {
                        Termination::Completed => None,
                        Termination::Error(error) => Some(error),
                    },
                )
                .await
            });
        },
    );
    BridgeSubscription { _sub: sub }
}
