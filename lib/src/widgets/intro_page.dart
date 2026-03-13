import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:transparent_wallet/src/rust/api/context.dart';
import 'package:transparent_wallet/src/rust/api/app_mode.dart';
import 'package:transparent_wallet/src/rust/utils/never.dart';
import 'package:transparent_wallet/src/utils/bridge_helper.dart';
import 'package:transparent_wallet/src/utils/device_secret.dart';
import 'package:transparent_wallet/src/widgets/settings_page.dart';
import 'common/localized_text.dart';
import 'common/pin_input_sheet.dart';

class IntroPage extends StatefulWidget {
  const IntroPage({super.key, required this.appContext});

  final Context appContext;

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late final Future<List<int>> _deviceSecretFuture;

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

  @override
  void initState() {
    super.initState();
    _deviceSecretFuture = DeviceSecretManager.getDeviceSecretBytes();
  }

  void _onNext() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutQuart,
      );
    }
  }

  Future<void> _setAppMode(AppMode mode) async {
    switch (mode) {
      case AppMode.coldWallet:
        await _ensurePinThenSwitchToCold();
        return;
      case AppMode.hotWallet:
      case AppMode.init:
        await _switchMode(mode);
    }
  }

  Future<List<int>?> _getDeviceSecretOrShowError(String errorTextId) async {
    try {
      return await _deviceSecretFuture;
    } catch (e) {
      _showLocalizedSnack(errorTextId, args: {'error': e.toString()});
      return null;
    }
  }

  Future<void> _ensurePinThenSwitchToCold() async {
    final hasPin = await _getHasPinOnce();
    if (hasPin == null) return; // Already handled error display

    if (!hasPin) {
      final newPin = await _promptPinTwice(
        titleKey: 'pin-create-title',
        firstSubtitleKey: 'pin-create-subtitle',
        confirmSubtitleKey: 'pin-create-confirm-subtitle',
      );
      if (newPin == null) return;

      final deviceSecret =
          await _getDeviceSecretOrShowError('err-pin-create');
      if (deviceSecret == null) return;

      try {
        await widget.appContext.createPin(
          pin: utf8.encode(newPin),
          deviceSecret: deviceSecret,
        );
        _showLocalizedSnack('msg-pin-created');
      } catch (error) {
        _showLocalizedSnack(
          'err-pin-create',
          args: {'error': error.toString()},
        );
        return;
      }
    }

    await _switchMode(AppMode.coldWallet);
  }

  Future<bool?> _getHasPinOnce() async {
    try {
      final stream = convertSubscriptionToStream<bool, BridgeNever>((
        onNext,
        onTermination,
      ) {
        return widget.appContext.hasPinStream(
          onNext: onNext,
          onTermination: onTermination,
        );
      });
      return await stream.first;
    } catch (error) {
      _showLocalizedSnack(
        'error-setting-mode',
        args: {'error': error.toString()},
      );
      return null;
    }
  }

  Future<void> _switchMode(AppMode mode) async {
    try {
      await widget.appContext.setAppMode(appMode: mode);
    } catch (error) {
      _showLocalizedSnack(
        'error-setting-mode',
        args: {'error': error.toString()},
      );
    }
  }

  Future<String?> _promptPinTwice({
    required String titleKey,
    required String firstSubtitleKey,
    required String confirmSubtitleKey,
  }) async {
    final first = await showPinInputSheet(
      context: context,
      appContext: widget.appContext,
      titleKey: titleKey,
      subtitleKey: firstSubtitleKey,
    );
    if (!mounted) return null;
    if (first == null) return null;
    if (first.length != 6) {
      _showLocalizedSnack('err-pin-length');
      return null;
    }

    final confirm = await showPinInputSheet(
      context: context,
      appContext: widget.appContext,
      titleKey: titleKey,
      subtitleKey: confirmSubtitleKey,
    );
    if (!mounted) return null;
    if (confirm == null) return null;
    if (confirm.length != 6) {
      _showLocalizedSnack('err-pin-length');
      return null;
    }

    if (first != confirm) {
      _showLocalizedSnack('err-pin-mismatch');
      return null;
    }

    return first;
  }

  void _showLocalizedSnack(String textId, {Map<String, String>? args}) {
    if (!mounted) return;
    final resolvedArgs = args ?? const <String, String>{};
    widget.appContext.lookupLocalWithArgs(
      textId: textId,
      args: resolvedArgs,
      onNext: (msg) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(msg)));
        }
      },
      onTermination: (_) {},
    );
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
