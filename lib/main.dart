import 'dart:async';
import 'package:flutter/material.dart';
import 'package:janus_wallet/src/rust/frb_generated.dart';
import 'package:janus_wallet/src/utils/logger.dart';
import 'package:janus_wallet/src/utils/app_context.dart';
import 'package:janus_wallet/src/widgets/my_app.dart';

Future<void> main() async {
  // Init flutter_rust_bridge
  await RustLib.init();

  // Init rust logger
  initRustLogger();

  // Wait for Flutter Widgets to initialize
  WidgetsFlutterBinding.ensureInitialized();

  // Init app context
  await initAppContext();

  runApp(MyApp());
}
