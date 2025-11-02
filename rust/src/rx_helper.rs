use flutter_rust_bridge::DartFnFuture;
use rx_rust::{
    disposable::subscription::Subscription,
    observable::{observable_ext::ObservableExt, Observable},
    observer::Termination,
};
use std::sync::{Arc, Mutex};
use tokio::runtime::Handle;

pub(crate) fn subscribe_with_callback<'or, T, E, OE>(
    callback: impl Fn(Option<T>, Option<E>) -> DartFnFuture<()> + Send + 'static,
    observable_builder: impl FnOnce(Handle) -> OE,
) -> Subscription<'static>
where
    T: 'or,
    E: 'or,
    OE: Observable<'or, 'static, T, E>,
{
    let runtime = tokio::runtime::Handle::current();
    let runtime_cloned = runtime.clone();
    let callback = Arc::new(Mutex::new(callback));
    let callback_cloned = callback.clone();

    let observable = observable_builder(runtime.clone());
    let sub = observable.subscribe_with_callback(
        move |value| {
            runtime.spawn(callback.lock().unwrap()(Some(value), None));
        },
        move |termination| {
            runtime_cloned.spawn(callback_cloned.lock().unwrap()(
                None,
                match termination {
                    Termination::Completed => None,
                    Termination::Error(error) => Some(error),
                },
            ));
        },
    );
    sub
}
