import 'package:flutter/material.dart';
import 'package:transparent_wallet/src/rust/api/context.dart';
import 'package:transparent_wallet/src/rust/api/app_mode.dart';
import 'package:transparent_wallet/src/rust/api/localization.dart';
import 'package:transparent_wallet/src/rust/utils/bridge_helper.dart';
import 'common/localized_text.dart';

class IntroPage extends StatefulWidget {
  const IntroPage({super.key, required this.appContext});

  final Context appContext;

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_IntroSlide> _slides = [
    const _IntroSlide(
      titleKey: 'lang-title',
      descriptionKey: 'lang-desc',
      icon: Icons.language_outlined,
      color: Colors.indigo,
      isLanguage: true,
    ),
    const _IntroSlide(
      titleKey: 'intro-title-1',
      descriptionKey: 'intro-desc-1',
      icon: Icons.account_balance_wallet_outlined,
      color: Color(0xFF6C63FF),
    ),
    const _IntroSlide(
      titleKey: 'intro-title-2',
      descriptionKey: 'intro-desc-2',
      icon: Icons.security_outlined,
      color: Color(0xFF00BFA5),
    ),
    const _IntroSlide(
      titleKey: 'intro-title-3',
      descriptionKey: 'intro-desc-3',
      icon: Icons.rocket_launch_outlined,
      color: Color(0xFFFF6584),
      isLast: true,
    ),
  ];

  void _onNext() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _setLanguage(Language? language) async {
    await widget.appContext.setLanguage(language: language);
  }

  Future<void> _setAppMode(AppMode mode) async {
    try {
      await widget.appContext.setAppMode(appMode: mode);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: LocalizedText(
            'error-setting-mode',
            args: {'error': error.toString()},
            appContext: widget.appContext,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _slides.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              return _IntroSlideWidget(
                slide: _slides[index],
                onNext: _onNext,
                onSelectMode: _setAppMode,
                onSelectLanguage: _setLanguage,
                appContext: widget.appContext,
              );
            },
          ),
          Positioned(
            bottom: 48,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _slides.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 8,
                  width: _currentPage == index ? 24 : 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? _slides[_currentPage].color
                        : Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IntroSlide {
  final String titleKey;
  final String descriptionKey;
  final IconData icon;
  final Color color;
  final bool isLast;
  final bool isLanguage;

  const _IntroSlide({
    required this.titleKey,
    required this.descriptionKey,
    required this.icon,
    required this.color,
    this.isLast = false,
    this.isLanguage = false,
  });
}

class _IntroSlideWidget extends StatefulWidget {
  const _IntroSlideWidget({
    required this.slide,
    required this.onNext,
    required this.onSelectMode,
    required this.onSelectLanguage,
    required this.appContext,
  });

  final _IntroSlide slide;
  final VoidCallback onNext;
  final Function(AppMode) onSelectMode;
  final Function(Language?) onSelectLanguage;
  final Context appContext;

  @override
  State<_IntroSlideWidget> createState() => _IntroSlideWidgetState();
}

class _IntroSlideWidgetState extends State<_IntroSlideWidget> {
  Language? _currentLang;
  BridgeSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    if (widget.slide.isLanguage) {
      _subscribe();
    }
  }

  @override
  void dispose() {
    _subscription?.dispose();
    super.dispose();
  }

  Future<void> _subscribe() async {
    _subscription = await widget.appContext.languageStream(
      onNext: (lang) {
        if (mounted) {
          setState(() {
            _currentLang = lang;
          });
        }
      },
      onTermination: (_) {},
    );
  }

  void _showLanguagePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _LanguagePickerItem(
                  labelKey: 'lang-zh',
                  icon: Icons.translate,
                  color: Colors.redAccent,
                  onTap: () {
                    widget.onSelectLanguage(Language.chinese);
                    Navigator.pop(context);
                  },
                  appContext: widget.appContext,
                ),
                _LanguagePickerItem(
                  labelKey: 'lang-en',
                  icon: Icons.abc,
                  color: Colors.blueAccent,
                  onTap: () {
                    widget.onSelectLanguage(Language.english);
                    Navigator.pop(context);
                  },
                  appContext: widget.appContext,
                ),
                _LanguagePickerItem(
                  labelKey: 'lang-system',
                  icon: Icons.settings_suggest_outlined,
                  color: Colors.blueGrey,
                  onTap: () {
                    widget.onSelectLanguage(null);
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
    // Determine dynamic icons/colors for language slide
    final (langIcon, langColor, langLabelKey) = widget.slide.isLanguage
        ? switch (_currentLang) {
            Language.chinese => (Icons.translate, Colors.redAccent, 'lang-zh'),
            Language.english => (Icons.abc, Colors.blueAccent, 'lang-en'),
            null => (
              Icons.settings_suggest_outlined,
              Colors.blueGrey,
              'lang-system',
            ),
          }
        : (widget.slide.icon, widget.slide.color, null);

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, langColor.withValues(alpha: 0.1)],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2),
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: langColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(langIcon, size: 80, color: langColor),
          ),
          const SizedBox(height: 48),
          LocalizedText(
            widget.slide.titleKey,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
            appContext: widget.appContext,
          ),
          const SizedBox(height: 16),
          LocalizedText(
            widget.slide.descriptionKey,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: Colors.black54, height: 1.5),
            textAlign: TextAlign.center,
            appContext: widget.appContext,
          ),
          const Spacer(flex: 2),
          if (widget.slide.isLanguage) ...[
            _LanguageSelectorButton(
              labelKey: langLabelKey!,
              icon: langIcon,
              color: langColor,
              onPressed: () => _showLanguagePicker(context),
              appContext: widget.appContext,
            ),
            const SizedBox(height: 32),
            TextButton(
              onPressed: widget.onNext,
              child: LocalizedText(
                'btn-next',
                style: TextStyle(
                  color: widget.slide.color,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                appContext: widget.appContext,
              ),
            ),
          ] else if (widget.slide.isLast) ...[
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => widget.onSelectMode(AppMode.coldWallet),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                ),
                child: LocalizedText(
                  'btn-cold-wallet',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  appContext: widget.appContext,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => widget.onSelectMode(AppMode.hotWallet),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                ),
                child: LocalizedText(
                  'btn-hot-wallet',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  appContext: widget.appContext,
                ),
              ),
            ),
          ] else
            TextButton(
              onPressed: widget.onNext,
              child: LocalizedText(
                'btn-next',
                style: TextStyle(
                  color: widget.slide.color,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                appContext: widget.appContext,
              ),
            ),
          const Spacer(flex: 1),
          const SizedBox(height: 48),
        ],
      ),
    );
  }
}

class _LanguageSelectorButton extends StatelessWidget {
  const _LanguageSelectorButton({
    required this.labelKey,
    required this.icon,
    required this.color,
    required this.onPressed,
    required this.appContext,
  });

  final String labelKey;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;
  final Context appContext;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: color.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 12),
            LocalizedText(
              labelKey,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              appContext: appContext,
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_drop_down, color: Colors.grey),
          ],
        ),
      ),
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
  });

  final String labelKey;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final Context appContext;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 20, color: color),
      ),
      title: LocalizedText(
        labelKey,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        appContext: appContext,
      ),
      trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
      onTap: onTap,
    );
  }
}
