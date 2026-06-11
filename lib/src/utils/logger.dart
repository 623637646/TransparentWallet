import 'dart:io';
import 'package:janus_wallet/src/rust/api/context.dart';
import 'package:logger/logger.dart';

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

void logFromRust(LogEntry logEntry) {
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
