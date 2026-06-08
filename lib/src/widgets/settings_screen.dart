import 'dart:async';
import 'package:flutter/material.dart';
import '../rust/api/app_mode.dart';
import '../rust/utils/never.dart';
import '../utils/app_context.dart';
import '../utils/bridge_helper.dart';
import '../utils/design_tokens.dart';
import 'common/language_selection_bottom_sheet.dart';
import 'common/localized_text.dart';
import 'common/pin_bottom_sheet.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late Stream<bool> _hasPinStream;
  StreamSubscription<bool>? _hasPinSub;
  bool _hasPin = false;

  @override
  void initState() {
    super.initState();
    _hasPinStream = convertSubscriptionToStream<bool, BridgeNever>((
      onNext,
      onTermination,
    ) {
      return appContext.hasPinStream(
        onNext: onNext,
        onTermination: onTermination,
      );
    });
    _hasPinSub = _hasPinStream.listen((event) {
      if (mounted) {
        setState(() {
          _hasPin = event;
        });
      }
    });
  }

  @override
  void dispose() {
    _hasPinSub?.cancel();
    super.dispose();
  }

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
                icon: _hasPin ? Icons.lock_open_outlined : Icons.lock_outline,
                titleKey: _hasPin ? 'settings-modify-pin' : 'settings-create-pin',
                onTap: () {
                  PinBottomSheet.show(
                    context,
                    mode: _hasPin ? PinBottomSheetMode.modify : PinBottomSheetMode.create,
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
                            appContext: appContext,
                            style: DesignTokens.typography.bodyStrong.copyWith(
                              color: tokens.colors.ink,
                              fontSize: 18.0,
                            ),
                          ),
                        ],
                      ),
                      content: LocalizedText(
                        'settings-reset-warning-message',
                        appContext: appContext,
                        style: DesignTokens.typography.body.copyWith(
                          color: tokens.colors.ink,
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: LocalizedText(
                            'settings-reset-warning-cancel',
                            appContext: appContext,
                            style: DesignTokens.typography.buttonUtility.copyWith(
                              color: tokens.colors.bodyMuted,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: LocalizedText(
                            'settings-reset-warning-confirm',
                            appContext: appContext,
                            style: DesignTokens.typography.buttonUtility.copyWith(
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
                      await appContext.setAppMode(appMode: AppMode.init);
                      if (context.mounted) {
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      }
                    } catch (e) {
                      debugPrint("Failed to reset app mode: $e");
                    }
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
