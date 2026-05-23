import 'dart:async';
import 'package:janus_wallet/src/rust/utils/bridge_helper.dart';

/// Converts a `flutter_rust_bridge` [Future<BridgeSubscription>] into a [Stream]
/// for reactive UI consumption.
///
/// This is typically used to bridge Rust subscriptions to the Flutter UI layer,
/// allowing the resulting [Stream] to be consumed directly via [StreamBuilder].
Stream<T> convertSubscriptionToStream<T, E extends Object>(
  Future<BridgeSubscription> Function(
    FutureOr<void> Function(T) onNext,
    FutureOr<void> Function(E?) onTermination,
  )
  subscriptionBuilder,
) {
  final controller = StreamController<T>();

  Null onNext(value) {
    if (controller.isClosed) return;
    controller.add(value);
  }

  Null onTermination(error) {
    if (controller.isClosed) return;
    switch (error) {
      case (E error):
        controller.addError(error);
        break;
      case (null):
        controller.close();
        break;
    }
  }

  final sub = subscriptionBuilder(onNext, onTermination);
  controller.onCancel = () async => (await sub).dispose();
  return controller.stream;
}
