import 'package:flutter/material.dart';
import 'package:transparent_wallet/src/rust/api/context.dart';
import 'package:transparent_wallet/src/rust/api/localization.dart';
import 'package:transparent_wallet/src/rust/utils/never.dart';
import 'package:transparent_wallet/src/utils/bridge_helper.dart';
import 'common/localized_text.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key, required this.appContext});

  final Context appContext;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: LocalizedText('settings-title', appContext: appContext),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            clipBehavior: Clip.antiAlias,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
            ),
            color: Colors.white,
            child: Column(
              children: [
                _LanguageSettingItem(appContext: appContext),
                // Add more settings items here in the future
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageSettingItem extends StatefulWidget {
  const _LanguageSettingItem({required this.appContext});

  final Context appContext;

  @override
  State<_LanguageSettingItem> createState() => _LanguageSettingItemState();
}

class _LanguageSettingItemState extends State<_LanguageSettingItem> {
  late final Stream<Language?> _stream;

  @override
  void initState() {
    super.initState();
    _stream = convertSubscriptionToStream<Language?, BridgeNever>(
      (onNext, onTermination) => widget.appContext.languageStream(
        onNext: onNext,
        onTermination: onTermination,
      ),
    );
  }

  void _showLanguagePicker(BuildContext context, Language? currentLang) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: LocalizedText(
                    'settings-language',
                    style: Theme.of(context).textTheme.titleLarge,
                    appContext: widget.appContext,
                  ),
                ),
                const SizedBox(height: 16),
                _LanguagePickerItem(
                  labelKey: 'lang-zh',
                  icon: Icons.translate,
                  color: Colors.redAccent,
                  isSelected: currentLang == Language.chinese,
                  onTap: () {
                    widget.appContext.setLanguage(language: Language.chinese);
                    Navigator.pop(context);
                  },
                  appContext: widget.appContext,
                ),
                const SizedBox(height: 8),
                _LanguagePickerItem(
                  labelKey: 'lang-en',
                  icon: Icons.abc,
                  color: Colors.blueAccent,
                  isSelected: currentLang == Language.english,
                  onTap: () {
                    widget.appContext.setLanguage(language: Language.english);
                    Navigator.pop(context);
                  },
                  appContext: widget.appContext,
                ),
                const SizedBox(height: 8),
                _LanguagePickerItem(
                  labelKey: 'lang-system',
                  icon: Icons.settings_suggest_outlined,
                  color: Colors.blueGrey,
                  isSelected: currentLang == null,
                  onTap: () {
                    widget.appContext.setLanguage(language: null);
                    Navigator.pop(context);
                  },
                  appContext: widget.appContext,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Language?>(
      stream: _stream,
      builder: (context, snapshot) {
        final currentLang = snapshot.data;
        final bool isInitialLoading =
            snapshot.connectionState == ConnectionState.waiting &&
                currentLang == null;

        final langLabelKey = switch (currentLang) {
          Language.chinese => 'lang-zh',
          Language.english => 'lang-en',
          null => 'lang-system',
        };

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blueGrey.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.language, color: Colors.blueGrey, size: 20),
          ),
          title: LocalizedText(
            'settings-language',
            style: const TextStyle(fontWeight: FontWeight.w500),
            appContext: widget.appContext,
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isInitialLoading)
                LocalizedText(
                  langLabelKey,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  appContext: widget.appContext,
                )
              else
                const SizedBox.shrink(),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
          onTap: () => _showLanguagePicker(context, currentLang),
        );
      },
    );
  }
}

class _LanguagePickerItem extends StatelessWidget {
  const _LanguagePickerItem({
    required this.labelKey,
    required this.icon,
    required this.color,
    required this.onTap,
    required this.appContext,
    this.isSelected = false,
  });

  final String labelKey;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final Context appContext;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: LocalizedText(
                labelKey,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? color : Colors.black87,
                ),
                appContext: appContext,
              ),
            ),
            if (isSelected) Icon(Icons.check, color: color, size: 20),
          ],
        ),
      ),
    );
  }
}
