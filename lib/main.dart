import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:janus_wallet/src/rust/frb_generated.dart';
import 'package:janus_wallet/src/utils/logger.dart';
import 'package:janus_wallet/src/widgets/my_app.dart';

Future<void> main() async {
  // Init flutter_rust_bridge
  await RustLib.init();

  // Init rust logger
  initRustLogger();

  // Wait for Flutter Widgets to initialize
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}
