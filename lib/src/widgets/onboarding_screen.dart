import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../rust/api/app_mode.dart';
import '../utils/app_context.dart';
import '../utils/design_tokens.dart';
import 'common/localized_text.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  static const int _numPages = 4;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  Future<void> _selectAppMode(AppMode mode) async {
    try {
      await appContext.setAppMode(appMode: mode);
    } catch (e) {
      // In production we would log this using the Logger utility
      debugPrint("Failed to set app mode: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = DesignTheme.of(context);
    final btnPrimary = tokens.components.buttonPrimary;
    final btnSecondary = tokens.components.buttonSecondaryPill;

    return Scaffold(
      backgroundColor: tokens.colors.canvas, // Canvas color
      body: SafeArea(
        child: Column(
          children: [
            // Carousel Pages
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                children: [
                  _buildSlide(
                    pageIndex: 0,
                    icon: Icons.account_balance_wallet_outlined,
                    titleKey: 'onboarding-title-1',
                    bodyKey: 'onboarding-body-1',
                  ),
                  _buildSlide(
                    pageIndex: 1,
                    icon: Icons.ac_unit_outlined,
                    titleKey: 'onboarding-title-cold',
                    bodyKey: 'onboarding-body-cold',
                  ),
                  _buildSlide(
                    pageIndex: 2,
                    icon: Icons.local_fire_department_outlined,
                    titleKey: 'onboarding-title-hot',
                    bodyKey: 'onboarding-body-hot',
                  ),
                  _buildSlide(
                    pageIndex: 3,
                    icon: Icons.security_outlined,
                    titleKey: 'onboarding-title-3',
                    bodyKey: 'onboarding-body-3',
                    isLastPage: true,
                  ),
                ],
              ),
            ),

            // Bottom Navigation and Controls
            Padding(
              padding: EdgeInsets.only(
                left: DesignTokens.spacing.lg,
                right: DesignTokens.spacing.lg,
                bottom: DesignTokens.spacing.xl,
                top: 16.0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Actions with stable layout height and AnimatedSwitcher transition
                  SizedBox(
                    height: 124,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (Widget child, Animation<double> animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: child,
                        );
                      },
                      child: _currentPage < _numPages - 1
                          ? const SizedBox.shrink(key: ValueKey('empty_actions'))
                          : Column(
                              key: const ValueKey('mode_buttons'),
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Cold Wallet Button (Primary Ink Black Pill)
                                SizedBox(
                                  width: double.infinity,
                                  height: 54,
                                  child: ElevatedButton(
                                    onPressed: () => _selectAppMode(AppMode.coldWallet),
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
                                      'onboarding-btn-cold',
                                      appContext: appContext,
                                      style: DesignTokens.typography.body.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: btnPrimary.textColor,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16.0),
                                // Hot Wallet Button (Secondary White Pill with soft border/shadow)
                                SizedBox(
                                  width: double.infinity,
                                  height: 54,
                                  child: OutlinedButton(
                                    onPressed: () => _selectAppMode(AppMode.hotWallet),
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor: btnSecondary.backgroundColor,
                                      foregroundColor: btnSecondary.textColor,
                                      side: btnSecondary.border,
                                      elevation: 0,
                                      padding: btnSecondary.padding,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: btnSecondary.borderRadius,
                                      ),
                                    ),
                                    child: LocalizedText(
                                      'onboarding-btn-hot',
                                      appContext: appContext,
                                      style: DesignTokens.typography.body.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: btnSecondary.textColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 24.0),

                  // Page Indicators below the action buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _numPages,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 4.0),
                        height: 8.0,
                        width: _currentPage == index ? 24.0 : 8.0,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? tokens.colors.primary // active indicator
                              : tokens.colors.surfaceChipTranslucent, // inactive indicator
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlide({
    required int pageIndex,
    required IconData icon,
    required String titleKey,
    required String bodyKey,
    bool isLastPage = false,
  }) {
    final tokens = DesignTheme.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: DesignTokens.spacing.xl),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Large Geometric Icon with premium looping micro-animation
              OnboardingAnimatedIcon(
                pageIndex: pageIndex,
                isActive: _currentPage == pageIndex,
                icon: icon,
              ),
              SizedBox(height: DesignTokens.spacing.xxl),

              // Title Header
              LocalizedText(
                titleKey,
                appContext: appContext,
                textAlign: TextAlign.center,
                style: DesignTokens.typography.lead.copyWith(
                  color: tokens.colors.ink,
                ),
              ),
              const SizedBox(height: 16.0),

              // Description Body
              LocalizedText(
                bodyKey,
                appContext: appContext,
                textAlign: TextAlign.center,
                style: DesignTokens.typography.body.copyWith(
                  color: tokens.colors.bodyMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OnboardingAnimatedIcon extends StatefulWidget {
  final int pageIndex;
  final bool isActive;
  final IconData icon;

  const OnboardingAnimatedIcon({
    super.key,
    required this.pageIndex,
    required this.isActive,
    required this.icon,
  });

  @override
  State<OnboardingAnimatedIcon> createState() => _OnboardingAnimatedIconState();
}

class _OnboardingAnimatedIconState extends State<OnboardingAnimatedIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: _getDuration(),
    );
    if (widget.isActive) {
      _controller.repeat();
    }
  }

  Duration _getDuration() {
    switch (widget.pageIndex) {
      case 1:
        return const Duration(milliseconds: 12000); // Cold: slow rotate
      case 2:
        return const Duration(milliseconds: 2000); // Hot: pulsing ripple
      default:
        return const Duration(seconds: 2);
    }
  }

  @override
  void didUpdateWidget(covariant OnboardingAnimatedIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _controller.repeat();
      } else {
        _controller.stop();
        _controller.reset();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = DesignTheme.of(context);
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final double val = _controller.value;
        switch (widget.pageIndex) {
          case 1: // Cold Wallet: Slow rotation + breathing
            final double angle = val * 2 * math.pi;
            final double scale = 1.0 + math.sin(val * 4 * math.pi) * 0.03;
            return Transform.rotate(
              angle: angle,
              child: Transform.scale(
                scale: scale,
                child: child,
              ),
            );
          case 2: // Hot Wallet: Pulsing shield (outer ring ripples)
            final double pulseVal = val;
            final double pulseScale = 1.0 + pulseVal * 0.5;
            final double pulseOpacity = (1.0 - pulseVal).clamp(0.0, 1.0);
            return Stack(
              alignment: Alignment.center,
              children: [
                Transform.scale(
                  scale: pulseScale,
                  child: Opacity(
                    opacity: pulseOpacity,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: tokens.colors.primary.withValues(alpha: 0.3),
                          width: 2.0,
                        ),
                      ),
                    ),
                  ),
                ),
                child!,
              ],
            );
          default:
            return child!;
        }
      },
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: tokens.colors.canvasParchment,
          shape: BoxShape.circle,
        ),
        child: Icon(
          widget.icon,
          size: 56,
          color: tokens.colors.ink,
        ),
      ),
    );
  }
}
