import 'dart:async';
import 'package:flutter/material.dart';
import 'package:transparent_wallet/src/rust/api/app_settings.dart';
import 'package:transparent_wallet/src/rust/api/context.dart';
import 'package:transparent_wallet/src/rust/utils/never.dart';
import 'package:transparent_wallet/src/utils/bridge_helper.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.appContext});

  final Context appContext;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Transparent Wallet',
      home: _WalletModeRouter(appContext: appContext),
    );
  }
}

class _WalletModeRouter extends StatefulWidget {
  const _WalletModeRouter({required this.appContext});

  final Context appContext;

  @override
  State<_WalletModeRouter> createState() => _WalletModeRouterState();
}

class _WalletModeRouterState extends State<_WalletModeRouter> {
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

  Future<void> _setAppMode(AppMode mode) async {
    try {
      await widget.appContext.setAppMode(appMode: mode);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('切换钱包模式失败：$error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AppMode>(
      stream: _appModeStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _FullScreenMessage(
            title: '加载失败',
            message: '${snapshot.error}',
          );
        }

        final mode = snapshot.data;
        if (mode == null) {
          return const _FullScreenMessage(
            title: '加载中',
            message: '正在获取钱包状态…',
            showSpinner: true,
          );
        }

        switch (mode) {
          case AppMode.init:
            return WalletSetupPage(onSelectMode: _setAppMode);
          case AppMode.coldWallet:
          case AppMode.hotWallet:
            return WalletDemoPage(
              mode: mode,
              onReset: () => _setAppMode(AppMode.init),
            );
        }
      },
    );
  }
}

class WalletSetupPage extends StatelessWidget {
  const WalletSetupPage({super.key, required this.onSelectMode});

  final Future<void> Function(AppMode) onSelectMode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('选择钱包模式')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('当前状态：未设置', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 12),
            Text(
              '请选择冷钱包或热钱包，应用会保存选择并跳转到对应的演示页面。',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => onSelectMode(AppMode.coldWallet),
              child: const Text('冷钱包'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => onSelectMode(AppMode.hotWallet),
              child: const Text('热钱包'),
            ),
          ],
        ),
      ),
    );
  }
}

class WalletDemoPage extends StatelessWidget {
  const WalletDemoPage({super.key, required this.mode, required this.onReset})
    : assert(mode != AppMode.init);

  final AppMode mode;
  final Future<void> Function() onReset;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCold = mode == AppMode.coldWallet;
    final title = isCold ? '冷钱包' : '热钱包';
    final description = isCold
        ? '设备离线存储并签名交易，适合高安全场景的演示。'
        : '设备保持在线，便于快速交易与管理资产的演示。';

    return Scaffold(
      appBar: AppBar(title: Text('$title Demo')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('当前状态：$title', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 12),
            Text(description, style: theme.textTheme.bodyMedium),
            const Spacer(),
            ElevatedButton(onPressed: onReset, child: const Text('重置钱包')),
          ],
        ),
      ),
    );
  }
}

class _FullScreenMessage extends StatelessWidget {
  const _FullScreenMessage({
    required this.title,
    required this.message,
    this.showSpinner = false,
  });

  final String title;
  final String message;
  final bool showSpinner;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[
      Text(title, style: Theme.of(context).textTheme.headlineSmall),
      const SizedBox(height: 12),
      if (showSpinner)
        const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: CircularProgressIndicator(),
        ),
      Text(message, textAlign: TextAlign.center),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Transparent Wallet')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: children),
        ),
      ),
    );
  }
}
