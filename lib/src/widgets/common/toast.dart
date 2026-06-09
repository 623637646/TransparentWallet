import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:janus_wallet/src/rust/utils/bridge_helper.dart';
import 'package:janus_wallet/src/utils/app_context.dart';
import 'package:janus_wallet/src/utils/design_tokens.dart';

/// Reusable floating top Toast notification component.
class Toast {
  /// Displays a floating non-blocking Toast near the top of the screen.
  static void show(
    BuildContext context,
    String textId, {
    Map<String, String>? args,
  }) {
    final overlay = Overlay.of(context);

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) {
        return IgnorePointer(
          ignoring:
              true, // Toast is purely visual and does not block touch events.
          child: Stack(
            children: [
              Positioned(
                top: MediaQuery.of(context).padding.top + 16.0,
                left: 16.0,
                right: 16.0,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Material(
                    color: Colors.transparent,
                    child: _ToastWidget(
                      textId: textId,
                      args: args,
                      onDismiss: () {
                        entry.remove();
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    overlay.insert(entry);
  }
}

class _ToastWidget extends ConsumerStatefulWidget {
  final String textId;
  final Map<String, String>? args;
  final VoidCallback onDismiss;

  const _ToastWidget({
    required this.textId,
    this.args,
    required this.onDismiss,
  });

  @override
  ConsumerState<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends ConsumerState<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _fadeAnimation;

  Future<BridgeSubscription>? _subFuture;
  String? _resolvedText;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, -1.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    // Resolve text using the FFI Context and start timer
    final appContext = ref.read(appContextProvider).value;
    if (appContext != null) {
      _subFuture = appContext.lookUpText(
        textId: widget.textId,
        args: widget.args,
        onNext: (text) {
          if (mounted && _resolvedText == null) {
            setState(() {
              _resolvedText = text;
            });
            _startTimer(text);
          }
        },
        onTermination: (_) {},
      );
    } else {
      _resolvedText = widget.textId;
      _startTimer(widget.textId);
    }

    _controller.forward();
  }

  void _startTimer(String resolvedText) {
    // Dynamic duration based on text length: base 1500ms + 40ms per character, capped at 4000ms.
    final int durationMs = (1500 + resolvedText.length * 40).clamp(1500, 4000);
    _timer = Timer(Duration(milliseconds: durationMs), () {
      if (mounted) {
        _controller.reverse().then((_) {
          if (mounted) {
            widget.onDismiss();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _subFuture?.then((sub) => sub.dispose());
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = DesignTheme.of(context);

    return SlideTransition(
      position: _offsetAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: DesignTokens.spacing.md,
            vertical: DesignTokens.spacing.sm,
          ),
          decoration: BoxDecoration(
            color: tokens.colors.surfaceBlack,
            borderRadius: DesignTokens.rounded.pill,
            border: Border.all(
              color: tokens.colors.primary.withValues(alpha: 0.2),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 12.0,
                offset: const Offset(0.0, 6.0),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle_rounded,
                color: tokens.colors.primary,
                size: 20.0,
              ),
              SizedBox(width: DesignTokens.spacing.xs),
              Flexible(
                child: Text(
                  _resolvedText ?? '',
                  style: DesignTokens.typography.captionStrong.copyWith(
                    color: tokens.colors.bodyOnDark,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
