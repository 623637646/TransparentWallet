import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:janus_wallet/src/rust/frb_generated.dart';
import 'package:janus_wallet/src/widgets/my_app.dart';

Future<void> main() async {
  // Init flutter_rust_bridge
  await RustLib.init();

  runApp(const ProviderScope(child: MyApp()));
}
