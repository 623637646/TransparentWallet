import 'dart:async';
import 'package:flutter/material.dart';
import '../../rust/api/localization.dart';
import '../../rust/utils/never.dart';
import '../../utils/app_context.dart';
import '../../utils/design_tokens.dart';
import 'localized_text.dart';
import 'rust_stream_builder.dart';

class LanguageSelectionBottomSheet extends StatelessWidget {
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

  Future<void> _selectLanguage(BuildContext context, Language? language) async {
    await appContext.setLanguage(language: language);
    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = DesignTheme.of(context);

    Widget buildOptionsList(Language? selectedLang) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildOption(
            context,
            titleKey: 'language-option-system',
            isSelected: selectedLang == null,
            onTap: () => _selectLanguage(context, null),
          ),
          Divider(color: tokens.colors.dividerSoft, height: 1.0),
          _buildOption(
            context,
            titleKey: 'language-option-en',
            isSelected: selectedLang == Language.english,
            onTap: () => _selectLanguage(context, Language.english),
          ),
          Divider(color: tokens.colors.dividerSoft, height: 1.0),
          _buildOption(
            context,
            titleKey: 'language-option-zh',
            isSelected: selectedLang == Language.chinese,
            onTap: () => _selectLanguage(context, Language.chinese),
          ),
        ],
      );
    }

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
          RustStreamBuilder<Language?, BridgeNever>(
            subscriptionBuilder: (rustContext, onNext, onTermination) =>
                rustContext.languageStream(
              onNext: onNext,
              onTermination: onTermination,
            ),
            loadingBuilder: (context) => buildOptionsList(null),
            builder: (context, selectedLang) => buildOptionsList(selectedLang),
          ),
        ],
      ),
    );
  }

  Widget _buildOption(
    BuildContext context, {
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
