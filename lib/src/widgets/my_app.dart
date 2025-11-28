import 'dart:async';
import 'package:flutter/material.dart';
import 'package:transparent_wallet/src/rust/api/app_mode.dart';
import 'package:transparent_wallet/src/rust/api/context.dart';
import 'package:transparent_wallet/src/rust/utils/never.dart';
import 'package:transparent_wallet/src/utils/bridge_helper.dart';
import 'package:transparent_wallet/src/widgets/cold_wallet_demo_page.dart';
import 'package:transparent_wallet/src/widgets/hot_wallet_demo_page.dart';
import 'package:transparent_wallet/src/widgets/intro_page.dart';
import 'common/localized_text.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.appContext});

  final Context appContext;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String>(
      stream: convertSubscriptionToStream<String, String>(
        (onNext, onTermination) => appContext.lookupLocal(
          textId: 'app-name',
          onNext: onNext,
          onTermination: onTermination,
        ),
      ),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _FullScreenMessage(
            titleKey: 'loading-failed',
            content: Text('${snapshot.error}'),
            appContext: appContext,
          );
        }
        return MaterialApp(
          title: snapshot.data,
          home: WalletModeRouter(appContext: appContext),
        );
      },
    );
  }
}

class WalletModeRouter extends StatefulWidget {
  const WalletModeRouter({super.key, required this.appContext});

  final Context appContext;

  @override
  State<WalletModeRouter> createState() => _WalletModeRouterState();
}

class _WalletModeRouterState extends State<WalletModeRouter> {
  late final Stream<AppMode> _appModeStream;

  @override
  void initState() {
    super.initState();
    _appModeStream = convertSubscriptionToStream<AppMode, BridgeNever>(
      (onNext, onTermination) => widget.appContext.appModeStream(
        onNext: onNext,
        onTermination: onTermination,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AppMode>(
      stream: _appModeStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _FullScreenMessage(
            titleKey: 'loading-failed',
            content: Text('${snapshot.error}'),
            appContext: widget.appContext,
          );
        }

        final mode = snapshot.data;
        if (mode == null) {
          return _FullScreenMessage(
            titleKey: 'loading',
            content: LocalizedText(
              'loading-wallet-status',
              appContext: widget.appContext,
              textAlign: TextAlign.center,
            ),
            showSpinner: true,
            appContext: widget.appContext,
          );
        }

        switch (mode) {
          case AppMode.init:
            return IntroPage(appContext: widget.appContext);
          case AppMode.coldWallet:
            return ColdWalletDemoPage(appContext: widget.appContext);
          case AppMode.hotWallet:
            return HotWalletDemoPage(appContext: widget.appContext);
        }
      },
    );
  }
}

class _FullScreenMessage extends StatelessWidget {
  const _FullScreenMessage({
    required this.titleKey,
    required this.content,
    required this.appContext,
    this.showSpinner = false,
  });

  final String titleKey;
  final Widget content;
  final Context appContext;
  final bool showSpinner;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[
      LocalizedText(
        titleKey,
        style: Theme.of(context).textTheme.headlineSmall,
        appContext: appContext,
      ),
      const SizedBox(height: 12),
      if (showSpinner)
        const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: CircularProgressIndicator(),
        ),
      content,
    ];

    return Scaffold(
      appBar: AppBar(title: LocalizedText('app-name', appContext: appContext)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: children),
        ),
      ),
    );
  }
}
