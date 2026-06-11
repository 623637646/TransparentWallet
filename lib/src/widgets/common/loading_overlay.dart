import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/design_tokens.dart';

/// Global provider for managing the declarative loading state.
final globalLoadingProvider = NotifierProvider<GlobalLoadingNotifier, bool>(
  GlobalLoadingNotifier.new,
);

class GlobalLoadingNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void show() => state = true;
  void hide() => state = false;
}

/// A full-screen, gesture-blocking loading overlay with a premium glassmorphic blur
/// and a custom rotating spinner. Sits above all navigators, routes, and bottom sheets.
class GlobalLoadingOverlay extends ConsumerWidget {
  const GlobalLoadingOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(globalLoadingProvider);
    if (!isLoading) return const SizedBox.shrink();

    final tokens = DesignTheme.of(context);

    return Stack(
      children: [
        // Gesture blocker using opaque GestureDetector
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap:
                () {}, // Intentionally empty to intercept and absorb all taps
            child: const SizedBox.expand(),
          ),
        ),
        // Glassmorphic backdrop filter and theme-resolved overlay container
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
            child: Container(
              color: tokens.colors.canvas.withValues(alpha: 0.3),
            ),
          ),
        ),
        // Center alignment for the premium spinner without text
        const Center(child: ElegantSpinner()),
      ],
    );
  }
}

/// A premium, custom animated loading spinner featuring a rotating gradient sweep
/// with rounded stroke caps, styled with active theme tokens.
class ElegantSpinner extends StatefulWidget {
  const ElegantSpinner({super.key});

  @override
  State<ElegantSpinner> createState() => _ElegantSpinnerState();
}

class _ElegantSpinnerState extends State<ElegantSpinner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = DesignTheme.of(context);

    return RotationTransition(
      turns: _controller,
      child: CustomPaint(
        size: const Size(60.0, 60.0),
        painter: _SpinnerPainter(color: tokens.colors.primary),
      ),
    );
  }
}

class _SpinnerPainter extends CustomPainter {
  final Color color;

  _SpinnerPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 4.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromLTWH(0.0, 0.0, size.width, size.height);

    // Creates a sweep gradient where the tail fades out elegantly
    final gradient = SweepGradient(
      startAngle: 0.0,
      endAngle: math.pi * 2,
      colors: [
        color.withValues(alpha: 0.0),
        color.withValues(alpha: 0.25),
        color.withValues(alpha: 0.65),
        color,
      ],
      stops: const [0.0, 0.25, 0.65, 1.0],
      transform: const GradientRotation(-math.pi / 2),
    );

    paint.shader = gradient.createShader(rect);

    // Draw the gradient arc (spanning 300 degrees to leave a visual gap)
    canvas.drawArc(rect, 0.0, math.pi * 1.67, false, paint);
  }

  @override
  bool shouldRepaint(covariant _SpinnerPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
