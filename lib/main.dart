import 'dart:async';
import 'package:flutter/material.dart';
import 'package:transparent_wallet/src/rust/api/context.dart';
import 'package:transparent_wallet/src/rust/frb_generated.dart';
import 'package:transparent_wallet/src/utils/logger.dart';
import 'package:transparent_wallet/src/widgets/my_app.dart';
import 'package:sqflite/sqflite.dart';

Future<void> main() async {
  // Init flutter_rust_bridge
  await RustLib.init();

  // Init rust logger
  initRustLogger();

  // Init context
  WidgetsFlutterBinding.ensureInitialized();
  final workingDir = await getDatabasesPath();
  final context = await initContext(workingDir: workingDir);

  runApp(MyApp(appContext: context));
}
