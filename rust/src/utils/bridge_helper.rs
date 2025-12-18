use flutter_rust_bridge::{frb, DartFnFuture};
use rx_rust::{
    disposable::subscription::Subscription,
    observable::{observable_ext::ObservableExt, Observable},
    observer::Termination,
};
use std::sync::Arc;
use tokio::runtime::Handle;

#[frb(opaque)]
pub struct BridgeSubscription {
    _sub: Subscription<'static>,
}

pub(crate) fn subscribe_with_bridge_callback<T, E, OE>(
    observable_builder: impl FnOnce(Handle) -> OE,
    on_next: impl Fn(T) -> DartFnFuture<()> + Send + Sync + 'static,
    on_termination: impl Fn(Option<E>) -> DartFnFuture<()> + Send + Sync + 'static,
) -> BridgeSubscription
where
    T: Send + Sync + 'static,
    E: Send + Sync + 'static,
    OE: Observable<'static, 'static, T, E>,
{
    let runtime = tokio::runtime::Handle::current();
    let runtime_cloned = runtime.clone();
    let on_next = Arc::new(on_next);

    let observable = observable_builder(runtime.clone());
    let sub = observable.on_backpressure_buffer().subscribe_with_callback(
        move |(values, request)| {
            let on_next = on_next.clone();
            runtime.spawn(async move {
                for value in values {
                    on_next(value).await;
                }
                request();
            });
        },
        move |termination| {
            runtime_cloned.spawn(async move {
                on_termination(match termination {
                    Termination::Completed => None,
                    Termination::Error(error) => Some(error),
                })
                .await
            });
        },
    );
    BridgeSubscription { _sub: sub }
}
