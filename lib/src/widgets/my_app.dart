import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../rust/api/app_mode.dart';
import '../rust/utils/never.dart';
import '../utils/app_context.dart';
import '../utils/design_tokens.dart';
import 'common/rust_stream_builder.dart';
import 'common/loading_overlay.dart';
import 'onboarding_screen.dart';
import 'cold_wallet_home.dart';
import 'hot_wallet_home.dart';

/// The root widget of the Janus Wallet application.
///
/// It initializes the application context and dynamically switches between
/// operating modes (Cold Wallet, Hot Wallet, or Onboarding/Initialization)
/// with a radial transition animation.
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  static final Map<AppMode, GlobalKey> _appKeys = {
    AppMode.init: GlobalKey(debugLabel: 'init_app'),
    AppMode.coldWallet: GlobalKey(debugLabel: 'cold_app'),
    AppMode.hotWallet: GlobalKey(debugLabel: 'hot_app'),
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contextAsync = ref.watch(appContextProvider);

    return contextAsync.when(
      skipLoadingOnRefresh: false,
      loading: () => const SizedBox.shrink(),
      error: (error, stack) => _buildApp(
        mode: AppMode.init,
        home: _BootstrapErrorScreen(
          message: 'Failed to initialize app: $error',
        ),
      ),
      data: (rustContext) {
        return RustStreamBuilder<AppMode, BridgeNever>(
          subscriptionBuilder: (rustContext, onNext, onTermination) =>
              rustContext.appModeStream(
                onNext: onNext,
                onTermination: onTermination,
              ),
          errorBuilder: (context, error) => _buildApp(
            mode: AppMode.init,
            home: _BootstrapErrorScreen(message: 'Error: $error'),
          ),
          builder: (context, mode) {
            return AppModeRevealSwitcher(mode: mode);
          },
        );
      },
    );
  }

  /// Builds a [Widget] representing the entry page for the given [AppMode].
  static Widget _buildPageForMode(AppMode mode) {
    switch (mode) {
      case AppMode.init:
        return const OnboardingScreen();
      case AppMode.coldWallet:
        return const ColdWalletHome();
      case AppMode.hotWallet:
        return const HotWalletHome();
    }
  }

  /// Helper to build the application container configured for the given [AppMode].
  static Widget _buildAppForMode(AppMode mode) {
    return _buildApp(mode: mode, home: _buildPageForMode(mode));
  }

  /// Builds the top-level [MaterialApp] wrapped in the mode's [DesignTheme].
  static Widget _buildApp({required AppMode mode, required Widget home}) {
    final tokens = DesignTokens.of(mode);
    return DesignTheme(
      key: _appKeys[mode],
      tokens: tokens,
      child: MaterialApp(
        title: 'Janus Wallet',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: 'Inter',
          colorScheme: ColorScheme.fromSeed(
            seedColor: tokens.colors.primary,
            primary: tokens.colors.primary,
            surface: tokens.colors.canvas,
          ),
          useMaterial3: true,
        ),
        home: home,
        builder: (context, child) {
          return Stack(
            children: [
              // ignore: use_null_aware_elements
              if (child != null) child,
              const GlobalLoadingOverlay(),
            ],
          );
        },
      ),
    );
  }
}

/// A screen displayed when the application fails to bootstrap or encounters FFI stream errors.
class _BootstrapErrorScreen extends StatelessWidget {
  final String message;

  const _BootstrapErrorScreen({required this.message});

  @override
  Widget build(BuildContext context) {
    final tokens = DesignTokens.of(AppMode.init);
    return Scaffold(
      backgroundColor: tokens.colors.canvas,
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(DesignTokens.spacing.lg),
          child: Text(
            message,
            style: DesignTokens.typography.body.copyWith(
              color: tokens.colors.ink,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

/// Switcher widget that animates app mode transitions using a radial reveal.
class AppModeRevealSwitcher extends StatefulWidget {
  final AppMode mode;

  const AppModeRevealSwitcher({super.key, required this.mode});

  @override
  State<AppModeRevealSwitcher> createState() => _AppModeRevealSwitcherState();
}

class _AppModeRevealSwitcherState extends State<AppModeRevealSwitcher>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  AppMode? _previousMode;
  AppMode? _currentMode;

  @override
  void initState() {
    super.initState();
    _currentMode = widget.mode;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _previousMode = null;
          _controller.reset();
        });
      }
    });
  }

  @override
  void didUpdateWidget(covariant AppModeRevealSwitcher oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.mode != oldWidget.mode) {
      setState(() {
        _previousMode = oldWidget.mode;
        _currentMode = widget.mode;
      });
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prev = _previousMode;
    final curr = _currentMode!;

    if (prev == null) {
      return MyApp._buildAppForMode(curr);
    }

    return Stack(
      textDirection: TextDirection.ltr,
      children: [
        IgnorePointer(ignoring: true, child: MyApp._buildAppForMode(prev)),
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return ClipPath(
              clipper: RadialRevealClipper(fraction: _controller.value),
              child: child,
            );
          },
          child: MyApp._buildAppForMode(curr),
        ),
      ],
    );
  }
}

/// A clipper that shapes a child into an expanding circle, providing a radial reveal effect.
class RadialRevealClipper extends CustomClipper<Path> {
  final double fraction;

  RadialRevealClipper({required this.fraction});

  @override
  Path getClip(Size size) {
    final path = Path();
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius =
        math.sqrt(size.width * size.width + size.height * size.height) / 2;
    final radius = maxRadius * fraction;

    path.addOval(Rect.fromCircle(center: center, radius: radius));
    return path;
  }

  @override
  bool shouldReclip(covariant RadialRevealClipper oldClipper) {
    return oldClipper.fraction != fraction;
  }
}
