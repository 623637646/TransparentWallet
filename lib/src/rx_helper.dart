import 'dart:async';
import 'package:transparent_wallet/src/rust/api/simple.dart';

Stream<T> subscribeBridgeStream<T, E extends Object>(
  Future<Subscription> Function(FutureOr<void> Function(T?, E?)) apiCall,
) {
  var controller = StreamController<T>();
  var sub = apiCall((value, error) {
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
  });
  controller.onCancel = () async => (await sub).dispose();
  return controller.stream;
}
