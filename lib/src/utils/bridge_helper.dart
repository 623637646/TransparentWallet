import 'dart:async';
import 'package:transparent_wallet/src/rust/utils/bridge_helper.dart';

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
