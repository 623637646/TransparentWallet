import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:janus_wallet/src/rust/api/context.dart';
import 'package:janus_wallet/src/utils/logger.dart';
import 'package:janus_wallet/src/utils/secure_storage.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/foundation.dart';

/// FutureProvider that asynchronously initializes the application context.
final appContextProvider = FutureProvider<Context>((ref) async {
  return initAppContext();
});

/// Initializes the application context.
///
/// This function performs the following setup:
/// 1. Retrieves the local database directory path.
/// 2. Initializes the secure storage manager and its read/write/clean closures.
/// 3. Initializes the Rust core `Context` via FFI with the above dependencies.
/// 4. Synchronizes and listens to system language changes for i18n support.
///
/// Returns the initialized [Context] instance.
Future<Context> initAppContext() async {
  final workingDir = await getDatabasesPath();
  final secureStorageManager = SecureStorageManager();
  final writer = secureStorageManager.writer();
  final reader = secureStorageManager.reader();
  final cleaner = secureStorageManager.cleaner();

  final context = await initContext(
    workingDir: workingDir,
    logger: logFromRust,
    secureStorageWriter: writer,
    secureStorageReader: reader,
    secureStorageCleaner: cleaner,
  );

  // Set initial system languages
  await _updateSystemLanguages(context);

  // Listen for system language changes
  PlatformDispatcher.instance.onLocaleChanged = () async {
    await _updateSystemLanguages(context);
  };

  return context;
}

/// Updates the system languages in the Rust context.
///
/// Retrieves the current list of locales from Flutter's [PlatformDispatcher],
/// formats them into a list of language tags (e.g., 'en-US' or 'zh'),
/// and passes them to Rust for i18n matching.
Future<void> _updateSystemLanguages(Context context) async {
  final systemLocales = PlatformDispatcher.instance.locales;
  final languages = systemLocales.map((locale) {
    if (locale.countryCode != null) {
      return '${locale.languageCode}-${locale.countryCode}';
    } else {
      return locale.languageCode;
    }
  }).toList();
  await context.setSystemLanguages(languages: languages);
}

/// Extension on [WidgetRef] to allow convenient, synchronous access to the initialized [Context].
extension AppContextRef on WidgetRef {
  /// Retrieves the initialized Rust core FFI [Context] synchronously.
  Context get appContext => read(appContextProvider).requireValue;
}
