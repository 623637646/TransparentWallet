import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';
import 'package:janus_wallet/src/rust/utils/bridge_helper.dart';
import 'package:janus_wallet/src/utils/logger.dart';

/// A custom FFI handler that intercepts all Dart-Rust calls to log their inputs,
/// execution durations, and return values or exceptions.
class CustomLoggingHandler extends BaseHandler {
  /// Helper to sanitize and mask sensitive arguments (e.g., PINs or keys) before logging.
  Map<String, dynamic> _maskArguments(Map<String, dynamic> argMap) {
    const sensitiveKeys = {
      'pin',
      'oldpin',
      'newpin',
      'seed',
      'privatekey',
      'password',
      'secret',
      'key',
    };
    final masked = <String, dynamic>{};
    for (final entry in argMap.entries) {
      final keyLower = entry.key.toLowerCase();
      if (sensitiveKeys.any((k) => keyLower.contains(k))) {
        masked[entry.key] = '<REDACTED>';
      } else {
        masked[entry.key] = entry.value;
      }
    }
    return masked;
  }

  void _logStart(String mode, BaseTask task) {
    final maskedArgs = _maskArguments(task.argMap);
    logger.d(
      '[FFI $mode] 🚀 Start: ${task.constMeta.debugName} | Args: $maskedArgs',
    );
  }

  void _logSuccess(
    String mode,
    BaseTask task,
    DateTime startTime,
    Object? result,
  ) {
    final duration = DateTime.now().difference(startTime);
    logger.d(
      '[FFI $mode] ✅ Success: ${task.constMeta.debugName} in ${duration.inMilliseconds}ms | Result: $result',
    );
  }

  void _logError(
    String mode,
    BaseTask task,
    DateTime startTime,
    Object error,
    StackTrace stackTrace,
  ) {
    final duration = DateTime.now().difference(startTime);
    logger.e(
      '[FFI $mode] ❌ Error: ${task.constMeta.debugName} in ${duration.inMilliseconds}ms',
      error: error,
      stackTrace: stackTrace,
    );
  }

  @override
  Future<S> executeNormal<S, E extends Object>(NormalTask<S, E> task) async {
    // Skip logging if the return type is BridgeSubscription (e.g., stream setup)
    if (S == BridgeSubscription) {
      return super.executeNormal(task);
    }

    final startTime = DateTime.now();
    _logStart('Normal', task);
    try {
      final result = await super.executeNormal(task);
      _logSuccess('Normal', task, startTime, result);
      return result;
    } catch (e, s) {
      _logError('Normal', task, startTime, e, s);
      rethrow;
    }
  }

  @override
  S executeSync<S, E extends Object, WireSyncType>(
    SyncTask<S, E, WireSyncType> task,
  ) {
    final startTime = DateTime.now();
    _logStart('Sync', task);
    try {
      final result = super.executeSync(task);
      _logSuccess('Sync', task, startTime, result);
      return result;
    } catch (e, s) {
      _logError('Sync', task, startTime, e, s);
      rethrow;
    }
  }
}
