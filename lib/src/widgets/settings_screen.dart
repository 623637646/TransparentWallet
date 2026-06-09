import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../rust/utils/never.dart';
import '../utils/app_context.dart';
import '../utils/design_tokens.dart';
import 'common/language_selection_bottom_sheet.dart';
import 'common/localized_text.dart';
import 'common/pin_bottom_sheet.dart';
import 'common/rust_stream_builder.dart';

class SettingsScreen extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
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
          child: RustStreamBuilder<bool, BridgeNever>(
            subscriptionBuilder: (rustContext, onNext, onTermination) =>
                rustContext.hasPinStream(
                  onNext: onNext,
                  onTermination: onTermination,
                ),
            initialData: false,
            builder: (context, hasPin) {
              return Column(
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
                    icon: hasPin
                        ? Icons.lock_open_outlined
                        : Icons.lock_outline,
                    titleKey: hasPin
                        ? 'settings-modify-pin'
                        : 'settings-create-pin',
                    onTap: () {
                      PinBottomSheet.show(
                        context,
                        mode: hasPin
                            ? PinBottomSheetMode.modify
                            : PinBottomSheetMode.create,
                      );
                    },
                  ),
                  SizedBox(height: DesignTokens.spacing.md),
                  _buildSettingItem(
                    context,
                    icon: Icons.restart_alt_outlined,
                    titleKey: 'settings-reset-wallet-mode',
                    onTap: () async {
                      final tokens = DesignTheme.of(context);
                      final bool? confirmReset = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: tokens.colors.canvasParchment,
                          shape: RoundedRectangleBorder(
                            borderRadius: DesignTokens.rounded.md,
                          ),
                          title: Row(
                            children: [
                              const Icon(
                                Icons.warning_amber_rounded,
                                color: Color(0xFFFF385C),
                                size: 28.0,
                              ),
                              const SizedBox(width: 8.0),
                              LocalizedText(
                                'settings-reset-warning-title',
                                style: DesignTokens.typography.bodyStrong
                                    .copyWith(
                                      color: tokens.colors.ink,
                                      fontSize: 18.0,
                                    ),
                              ),
                            ],
                          ),
                          content: LocalizedText(
                            'settings-reset-warning-message',
                            style: DesignTokens.typography.body.copyWith(
                              color: tokens.colors.ink,
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: LocalizedText(
                                'settings-reset-warning-cancel',
                                style: DesignTokens.typography.buttonUtility
                                    .copyWith(color: tokens.colors.bodyMuted),
                              ),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: LocalizedText(
                                'settings-reset-warning-confirm',
                                style: DesignTokens.typography.buttonUtility
                                    .copyWith(
                                      color: const Color(0xFFFF385C),
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      );

                      if (confirmReset == true) {
                        try {
                          final appContext = ref.appContext;
                          await appContext.resetApp();
                          if (context.mounted) {
                            Navigator.of(
                              context,
                            ).popUntil((route) => route.isFirst);
                          }
                          ref.invalidate(appContextProvider);
                        } catch (e) {
                          debugPrint("Failed to reset app mode: $e");
                        }
                      }
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
