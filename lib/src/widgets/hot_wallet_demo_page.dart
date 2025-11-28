import 'package:flutter/material.dart';
import 'package:transparent_wallet/src/rust/api/app_mode.dart';
import 'package:transparent_wallet/src/rust/api/context.dart';
import 'common/localized_text.dart';

class HotWalletDemoPage extends StatelessWidget {
  const HotWalletDemoPage({super.key, required this.appContext});

  final Context appContext;

  Future<void> _resetWallet(BuildContext context) async {
    try {
      await appContext.setAppMode(appMode: AppMode.init);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: LocalizedText(
            'reset-wallet-failed',
            args: {'error': e.toString()},
            appContext: appContext,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: LocalizedText('hot-wallet-title', appContext: appContext),
        backgroundColor: Colors.orange,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.local_fire_department,
              size: 100,
              color: Colors.orange,
            ),
            const SizedBox(height: 20),
            LocalizedText(
              'hot-wallet-desc-1',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              appContext: appContext,
            ),
            const SizedBox(height: 10),
            LocalizedText('hot-wallet-desc-2', appContext: appContext),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => _resetWallet(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              child: LocalizedText('reset-wallet-btn', appContext: appContext),
            ),
          ],
        ),
      ),
    );
  }
}
