import 'dart:async';
import 'dart:io';
import 'package:logger/logger.dart';
import 'package:transparent_wallet/src/rust/api/logger.dart';
import 'package:transparent_wallet/src/rust/utils/never.dart';
import 'package:transparent_wallet/src/utils/bridge_helper.dart';

final Logger logger = Logger(
  printer: PrettyPrinter(
    methodCount: 0, // Number of method calls to be displayed
    errorMethodCount: 8, // Number of method calls if stacktrace is provided
    lineLength: 120, // Width of the output
    colors: !Platform
        .isIOS, // Colorful log messages. Disable for iOS due to this issues: https://github.com/flutter/flutter/issues/20663
    printEmojis: true, // Print an emoji for each log message
    // Should each log print contain a timestamp
    dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
  ),
);

StreamSubscription<LogEntry>? _loggerSubscription;

void initRustLogger() {
  assert(_loggerSubscription == null);

  final stream = convertSubscriptionToStream<LogEntry, BridgeNever>(
    (callback) => initLogger(callback: callback),
  );

  _loggerSubscription = stream.listen(
    _logEntry,
    onError: (Object error, StackTrace stackTrace) {
      logger.e(
        'Rust logger stream error',
        error: error,
        stackTrace: stackTrace,
      );
    },
    onDone: () => logger.i('Rust logger stream completed'),
  );
}

void _logEntry(LogEntry logEntry) {
  final message = '[${logEntry.tag}] ${logEntry.msg}';
  final time = DateTime.fromMillisecondsSinceEpoch(
    logEntry.timeMillis.toInt(),
    isUtc: true,
  ).toLocal();

  switch (logEntry.level) {
    case LogLevel.trace:
      logger.t(message, time: time);
      break;
    case LogLevel.debug:
      logger.d(message, time: time);
      break;
    case LogLevel.info:
      logger.i(message, time: time);
      break;
    case LogLevel.warn:
      logger.w(message, time: time);
      break;
    case LogLevel.error:
      logger.e(message, time: time);
      break;
  }
}
