import 'package:flutter/material.dart';
import 'package:transparent_wallet/src/rust/api/context.dart';
import 'package:transparent_wallet/src/rust/api/app_mode.dart';
import 'package:transparent_wallet/src/widgets/settings_page.dart';
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
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutQuart,
      );
    }
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
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar with Settings
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              SettingsPage(appContext: widget.appContext),
                        ),
                      );
                    },
                    icon: const Icon(Icons.settings_outlined),
                    tooltip: 'Settings',
                  ),
                ],
              ),
            ),

            // Slide Content
            Expanded(
              child: PageView.builder(
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
                    appContext: widget.appContext,
                  );
                },
              ),
            ),

            // Bottom Indicators
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _slides.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 8,
                    width: _currentPage == index ? 32 : 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? Theme.of(context).primaryColor
                          : Colors.grey.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
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

  const _IntroSlide({
    required this.titleKey,
    required this.descriptionKey,
    required this.icon,
    required this.color,
    this.isLast = false,
  });
}

class _IntroSlideWidget extends StatelessWidget {
  const _IntroSlideWidget({
    required this.slide,
    required this.onNext,
    required this.onSelectMode,
    required this.appContext,
  });

  final _IntroSlide slide;
  final VoidCallback onNext;
  final Function(AppMode) onSelectMode;
  final Context appContext;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          // Icon Circle
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: slide.color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(slide.icon, size: 80, color: slide.color),
          ),
          const SizedBox(height: 48),

          // Title
          LocalizedText(
            slide.titleKey,
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
            appContext: appContext,
          ),
          const SizedBox(height: 16),

          // Description
          LocalizedText(
            slide.descriptionKey,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
            appContext: appContext,
          ),
          const Spacer(),

          // Actions
          if (slide.isLast) ...[
            _ModeSelectionCard(
              titleKey: 'btn-cold-wallet',
              icon: Icons.ac_unit,
              color: Colors.blueAccent,
              onTap: () => onSelectMode(AppMode.coldWallet),
              appContext: appContext,
            ),
            const SizedBox(height: 16),
            _ModeSelectionCard(
              titleKey: 'btn-hot-wallet',
              icon: Icons.local_fire_department,
              color: Colors.orangeAccent,
              onTap: () => onSelectMode(AppMode.hotWallet),
              appContext: appContext,
            ),
          ] else
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: onNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: slide.color,
                  foregroundColor: Colors.white,
                ),
                child: LocalizedText(
                  'btn-next',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  appContext: appContext,
                ),
              ),
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _ModeSelectionCard extends StatelessWidget {
  const _ModeSelectionCard({
    required this.titleKey,
    required this.icon,
    required this.color,
    required this.onTap,
    required this.appContext,
  });

  final String titleKey;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final Context appContext;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: LocalizedText(
                  titleKey,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  appContext: appContext,
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
