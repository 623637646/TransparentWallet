import 'package:flutter/material.dart';
import 'package:transparent_wallet/src/rust/api/app_mode.dart';
import 'package:transparent_wallet/src/rust/api/context.dart';
import 'common/localized_text.dart';

class ColdWalletDemoPage extends StatelessWidget {
  const ColdWalletDemoPage({super.key, required this.appContext});

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
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: LocalizedText('cold-wallet-title', appContext: appContext),
        centerTitle: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(48),
                decoration: BoxDecoration(
                  color: Colors.blueGrey.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.ac_unit,
                  size: 80,
                  color: Colors.blueGrey,
                ),
              ),
              const SizedBox(height: 48),
              LocalizedText(
                'cold-wallet-desc-1',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
                appContext: appContext,
              ),
              const SizedBox(height: 16),
              LocalizedText(
                'cold-wallet-desc-2',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
                appContext: appContext,
              ),
              const SizedBox(height: 64),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: () => _resetWallet(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    side: const BorderSide(color: Colors.redAccent),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: LocalizedText(
                    'reset-wallet-btn',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    appContext: appContext,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
