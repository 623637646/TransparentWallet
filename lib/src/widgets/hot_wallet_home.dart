import 'package:flutter/material.dart';
import '../rust/api/app_mode.dart';
import '../utils/app_context.dart';
import '../utils/design_tokens.dart';
import 'common/localized_text.dart';

class HotWalletHome extends StatelessWidget {
  const HotWalletHome({super.key});

  Future<void> _resetAppMode() async {
    try {
      await appContext.setAppMode(appMode: AppMode.init);
    } catch (e) {
      debugPrint("Failed to reset app mode: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = DesignTheme.of(context);
    final btnPrimary = tokens.components.buttonPrimary;

    return Scaffold(
      backgroundColor: tokens.colors.canvas, // Canvas color
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
                SizedBox(height: DesignTokens.spacing.xxl),
                SizedBox(
                  width: 200,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _resetAppMode,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: btnPrimary.backgroundColor,
                      foregroundColor: btnPrimary.textColor,
                      elevation: 0,
                      padding: btnPrimary.padding,
                      shape: RoundedRectangleBorder(
                        borderRadius: btnPrimary.borderRadius,
                      ),
                    ),
                    child: LocalizedText(
                      'reset-app-mode',
                      appContext: appContext,
                      style: DesignTokens.typography.body.copyWith(
                        fontWeight: FontWeight.w600,
                        color: btnPrimary.textColor,
                      ),
                    ),
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

