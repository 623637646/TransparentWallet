import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../rust/api/app_mode.dart';
import '../rust/utils/never.dart';
import '../utils/app_context.dart';
import '../utils/design_tokens.dart';
import 'common/rust_stream_builder.dart';
import 'onboarding_screen.dart';
import 'cold_wallet_home.dart';
import 'hot_wallet_home.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contextAsync = ref.watch(appContextProvider);
    final initialTokens = DesignTokens.of(AppMode.init);

    return contextAsync.when(
      skipLoadingOnRefresh: false,
      loading: () => _buildApp(
        mode: AppMode.init,
        home: Scaffold(
          backgroundColor: initialTokens.colors.canvas,
          body: Center(
            child: CircularProgressIndicator(
              color: initialTokens.colors.primary,
            ),
          ),
        ),
      ),
      error: (error, stack) => _buildApp(
        mode: AppMode.init,
        home: Scaffold(
          backgroundColor: initialTokens.colors.canvas,
          body: Center(
            child: Text(
              'Failed to initialize app: $error',
              style: DesignTokens.typography.body.copyWith(
                color: initialTokens.colors.ink,
              ),
            ),
          ),
        ),
      ),
      data: (rustContext) {
        return RustStreamBuilder<AppMode, BridgeNever>(
          subscriptionBuilder: (rustContext, onNext, onTermination) =>
              rustContext.appModeStream(
                onNext: onNext,
                onTermination: onTermination,
              ),
          loadingBuilder: (context) => _buildApp(
            mode: AppMode.init,
            home: Scaffold(
              backgroundColor: initialTokens.colors.canvas,
              body: Center(
                child: CircularProgressIndicator(
                  color: initialTokens.colors.primary,
                ),
              ),
            ),
          ),
          errorBuilder: (context, error) => _buildApp(
            mode: AppMode.init,
            home: Scaffold(
              backgroundColor: initialTokens.colors.canvas,
              body: Center(
                child: Text(
                  'Error: $error',
                  style: DesignTokens.typography.body.copyWith(
                    color: initialTokens.colors.ink,
                  ),
                ),
              ),
            ),
          ),
          builder: (context, mode) {
            return AppModeRevealSwitcher(mode: mode);
          },
        );
      },
    );
  }
}

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
      return _buildAppForMode(curr);
    }

    return Stack(
      textDirection: TextDirection.ltr,
      children: [
        IgnorePointer(ignoring: true, child: _buildAppForMode(prev)),
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return ClipPath(
              clipper: RadialRevealClipper(fraction: _controller.value),
              child: child,
            );
          },
          child: _buildAppForMode(curr),
        ),
      ],
    );
  }
}

Widget _buildPageForMode(AppMode mode) {
  switch (mode) {
    case AppMode.init:
      return const OnboardingScreen();
    case AppMode.coldWallet:
      return const ColdWalletHome();
    case AppMode.hotWallet:
      return const HotWalletHome();
  }
}

final Map<AppMode, GlobalKey> _appKeys = {
  AppMode.init: GlobalKey(debugLabel: 'init_app'),
  AppMode.coldWallet: GlobalKey(debugLabel: 'cold_app'),
  AppMode.hotWallet: GlobalKey(debugLabel: 'hot_app'),
};

Widget _buildAppForMode(AppMode mode) {
  return _buildApp(mode: mode, home: _buildPageForMode(mode));
}

Widget _buildApp({required AppMode mode, required Widget home}) {
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
    ),
  );
}

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
