import 'dart:async';
import 'package:transparent_wallet/src/rust/utils/bridge_helper.dart';

Stream<T> convertSubscriptionToStream<T, E extends Object>(
  Future<BridgeSubscription> Function(FutureOr<void> Function(T?, E?))
  subscriptionBuilder,
) {
  final controller = StreamController<T>();

  Null callback(value, error) {
    if (controller.isClosed) return;
    switch ((value, error)) {
      case (T value, null):
        controller.add(value);
        break;
      case (null, E error):
        controller.addError(error);
        break;
      case (null, null):
        controller.close();
        break;
      default:
        assert(false);
        break;
    }
  }

  final sub = subscriptionBuilder(callback);
  controller.onCancel = () async => (await sub).dispose();
  return controller.stream;
}
