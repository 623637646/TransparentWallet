import 'dart:async';
import 'package:flutter/material.dart';
import '../../rust/api/localization.dart';
import '../../rust/utils/never.dart';
import '../../utils/app_context.dart';
import '../../utils/design_tokens.dart';
import '../../utils/bridge_helper.dart';
import 'localized_text.dart';

class LanguageSelectionBottomSheet extends StatefulWidget {
  const LanguageSelectionBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    final tokens = DesignTheme.of(context);
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: tokens.colors.canvasParchment,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(DesignTokens.rounded.lg.topLeft.x),
          topRight: Radius.circular(DesignTokens.rounded.lg.topRight.x),
        ),
      ),
      builder: (context) => const LanguageSelectionBottomSheet(),
    );
  }

  @override
  State<LanguageSelectionBottomSheet> createState() => _LanguageSelectionBottomSheetState();
}

class _LanguageSelectionBottomSheetState extends State<LanguageSelectionBottomSheet> {
  late Stream<Language?> _stream;

  @override
  void initState() {
    super.initState();
    _stream = convertSubscriptionToStream<Language?, BridgeNever>((onNext, onTermination) {
      return appContext.languageStream(
        onNext: onNext,
        onTermination: onTermination,
      );
    });
  }

  Future<void> _selectLanguage(Language? language) async {
    await appContext.setLanguage(language: language);
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = DesignTheme.of(context);

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          Container(
            margin: EdgeInsets.symmetric(vertical: DesignTokens.spacing.xs),
            width: 36.0,
            height: 4.0,
            decoration: BoxDecoration(
              color: tokens.colors.bodyMuted.withValues(alpha: 0.3),
              borderRadius: DesignTokens.rounded.pill,
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.symmetric(
              vertical: DesignTokens.spacing.sm,
              horizontal: DesignTokens.spacing.lg,
            ),
            child: LocalizedText(
              'language-selection-title',
              appContext: appContext,
              style: DesignTokens.typography.bodyStrong.copyWith(
                color: tokens.colors.ink,
              ),
            ),
          ),

          Divider(color: tokens.colors.dividerSoft, height: 1.0),

          // Options StreamBuilder
          StreamBuilder<Language?>(
            stream: _stream,
            builder: (context, snapshot) {
              final selectedLang = snapshot.data;

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildOption(
                    titleKey: 'language-option-system',
                    isSelected: selectedLang == null,
                    onTap: () => _selectLanguage(null),
                  ),
                  Divider(color: tokens.colors.dividerSoft, height: 1.0),
                  _buildOption(
                    titleKey: 'language-option-en',
                    isSelected: selectedLang == Language.english,
                    onTap: () => _selectLanguage(Language.english),
                  ),
                  Divider(color: tokens.colors.dividerSoft, height: 1.0),
                  _buildOption(
                    titleKey: 'language-option-zh',
                    isSelected: selectedLang == Language.chinese,
                    onTap: () => _selectLanguage(Language.chinese),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOption({
    required String titleKey,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final tokens = DesignTheme.of(context);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: DesignTokens.spacing.md,
          horizontal: DesignTokens.spacing.lg,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            LocalizedText(
              titleKey,
              appContext: appContext,
              style: DesignTokens.typography.body.copyWith(
                color: isSelected ? tokens.colors.primary : tokens.colors.ink,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check,
                color: tokens.colors.primary,
                size: 20.0,
              ),
          ],
        ),
      ),
    );
  }
}
