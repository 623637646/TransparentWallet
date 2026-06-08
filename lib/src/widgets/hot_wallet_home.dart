import 'package:flutter/material.dart';
import '../utils/app_context.dart';
import '../utils/design_tokens.dart';
import 'common/localized_text.dart';
import 'settings_screen.dart';

class HotWalletHome extends StatelessWidget {
  const HotWalletHome({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = DesignTheme.of(context);

    return Scaffold(
      backgroundColor: tokens.colors.canvas, // Canvas color
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.settings_outlined, color: tokens.colors.ink),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(DesignTokens.spacing.lg),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.local_fire_department_outlined, // Hot representation
                  size: 80,
                  color: tokens.colors.ink, // Ink
                ),
                SizedBox(height: DesignTokens.spacing.lg),
                LocalizedText(
                  'hot-wallet-title',
                  appContext: appContext,
                  style: DesignTokens.typography.displayMd.copyWith(
                    color: tokens.colors.ink,
                  ),
                ),
                SizedBox(height: DesignTokens.spacing.sm),
                LocalizedText(
                  'hot-wallet-desc',
                  appContext: appContext,
                  textAlign: TextAlign.center,
                  style: DesignTokens.typography.body.copyWith(
                    color: tokens.colors.bodyMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

