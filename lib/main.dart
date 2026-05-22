import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:janus_wallet/src/rust/api/context.dart';
import 'package:janus_wallet/src/rust/frb_generated.dart';
import 'package:janus_wallet/src/utils/logger.dart';
import 'package:janus_wallet/src/utils/secure_storage.dart';
import 'package:janus_wallet/src/widgets/my_app.dart';
import 'package:sqflite/sqflite.dart';

Future<void> updateSystemLanguages(Context context) async {
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

Future<void> main() async {
  // Init flutter_rust_bridge
  await RustLib.init();

  // Init rust logger
  initRustLogger();

  // Init context
  WidgetsFlutterBinding.ensureInitialized();
  final workingDir = await getDatabasesPath();
  final secureStorageManager = SecureStorageManager();
  final writer = secureStorageManager.writer();
  final reader = secureStorageManager.reader();
  final cleaner = secureStorageManager.cleaner();

  final context = await initContext(
    workingDir: workingDir,
    secureStorageWriter: writer,
    secureStorageReader: reader,
    secureStorageCleaner: cleaner,
  );

  // Set initial system languages
  await updateSystemLanguages(context);

  // Listen for system language changes
  PlatformDispatcher.instance.onLocaleChanged = () async {
    await updateSystemLanguages(context);
  };

  runApp(MyApp(appContext: context));
}
