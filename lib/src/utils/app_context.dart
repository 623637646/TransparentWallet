import 'dart:async';
import 'package:janus_wallet/src/rust/api/context.dart';
import 'package:janus_wallet/src/utils/secure_storage.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/foundation.dart';

/// Global application context instance providing interfaces to interact with the Rust core.
late Context appContext;

/// Initializes the application context.
///
/// This function performs the following setup:
/// 1. Retrieves the local database directory path.
/// 2. Initializes the secure storage manager and its read/write/clean closures.
/// 3. Initializes the Rust core `Context` via FFI with the above dependencies.
/// 4. Synchronizes and listens to system language changes for i18n support.
Future<void> initAppContext() async {
  final workingDir = await getDatabasesPath();
  final secureStorageManager = SecureStorageManager();
  final writer = secureStorageManager.writer();
  final reader = secureStorageManager.reader();
  final cleaner = secureStorageManager.cleaner();

  appContext = await initContext(
    workingDir: workingDir,
    secureStorageWriter: writer,
    secureStorageReader: reader,
    secureStorageCleaner: cleaner,
  );

  // Set initial system languages
  await _updateSystemLanguages(appContext);

  // Listen for system language changes
  PlatformDispatcher.instance.onLocaleChanged = () async {
    await _updateSystemLanguages(appContext);
  };
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
