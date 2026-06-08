import 'package:flutter/material.dart';
import '../rust/api/app_mode.dart';
import '../utils/app_context.dart';
import '../utils/design_tokens.dart';
import 'common/language_selection_bottom_sheet.dart';
import 'common/localized_text.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Widget _buildSettingItem(
    BuildContext context, {
    required IconData icon,
    required String titleKey,
    required VoidCallback onTap,
  }) {
    final tokens = DesignTheme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: DesignTokens.rounded.md,
      child: Container(
        padding: EdgeInsets.all(DesignTokens.spacing.md),
        decoration: BoxDecoration(
          color: tokens.colors.surfaceTile1,
          borderRadius: DesignTokens.rounded.md,
        ),
        child: Row(
          children: [
            Icon(icon, color: tokens.colors.ink, size: 24.0),
            SizedBox(width: DesignTokens.spacing.md),
            Expanded(
              child: LocalizedText(
                titleKey,
                appContext: appContext,
                style: DesignTokens.typography.body.copyWith(
                  color: tokens.colors.ink,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_outlined,
              color: tokens.colors.bodyMuted,
              size: 20.0,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = DesignTheme.of(context);

    return Scaffold(
      backgroundColor: tokens.colors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: tokens.colors.ink),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: LocalizedText(
          'settings-title',
          appContext: appContext,
          style: DesignTokens.typography.bodyStrong.copyWith(
            color: tokens.colors.ink,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: DesignTokens.spacing.lg,
            vertical: DesignTokens.spacing.md,
          ),
          child: Column(
            children: [
              _buildSettingItem(
                context,
                icon: Icons.language_outlined,
                titleKey: 'settings-change-language',
                onTap: () => LanguageSelectionBottomSheet.show(context),
              ),
              SizedBox(height: DesignTokens.spacing.md),
              _buildSettingItem(
                context,
                icon: Icons.restart_alt_outlined,
                titleKey: 'settings-reset-wallet-mode',
                onTap: () async {
                  try {
                    await appContext.setAppMode(appMode: AppMode.init);
                    if (context.mounted) {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    }
                  } catch (e) {
                    debugPrint("Failed to reset app mode: $e");
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
