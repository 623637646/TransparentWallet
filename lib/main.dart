import 'dart:async';
import 'package:flutter/material.dart';
import 'package:transparent_wallet/src/rust/api/simple.dart';
import 'package:transparent_wallet/src/rust/frb_generated.dart';
import 'package:transparent_wallet/src/rx_helper.dart';

Future<void> main() async {
  await RustLib.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Simple Navigation', home: const PageA());
  }
}

class PageA extends StatelessWidget {
  const PageA({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      appBar: AppBar(title: const Text('Page A')),
      body: Center(
        child: ElevatedButton(
          child: const Text('Go to Page B'),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const MyHomePage(title: "lll"),
              ),
            );
          },
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Stream<BigInt> ticks;

  @override
  void initState() {
    super.initState();
    ticks = subscribeBridgeStream<BigInt, double>(
      (callback) => tick(name: "Yanni", callback: callback),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text("Time since starting Rust stream"),
            StreamBuilder<BigInt>(
              stream: ticks,
              builder: (context, snap) {
                final style = Theme.of(context).textTheme.headlineMedium;
                final error = snap.error;
                if (error != null) {
                  return Tooltip(
                    message: error.toString(),
                    child: Text('Error', style: style),
                  );
                }

                final data = snap.data;
                if (data != null) return Text('$data second(s)', style: style);

                return const CircularProgressIndicator();
              },
            ),
          ],
        ),
      ),
    );
  }
}
