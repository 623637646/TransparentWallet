import 'package:flutter/material.dart';
import 'package:transparent_wallet/src/rust/api/context.dart';
import 'package:transparent_wallet/src/utils/bridge_helper.dart';
import 'package:transparent_wallet/src/utils/logger.dart';
import 'common/pin_input_sheet.dart';

/// Gate that prevents entering the app before PIN verification.
class PinGate extends StatefulWidget {
  const PinGate({
    super.key,
    required this.appContext,
    required this.child,
  });

  final Context appContext;
  final Widget child;

  @override
  State<PinGate> createState() => _PinGateState();
}

class _PinGateState extends State<PinGate> {
  bool _isChecking = true;
  bool _isVerified = false;

  @override
  void initState() {
    super.initState();
    _checkHasPin();
  }

  Future<void> _checkHasPin() async {
    try {
      final stream = convertSubscriptionToStream<bool, Object>(
        (onNext, onTermination) => widget.appContext.hasPinStream(
          onNext: onNext,
          onTermination: (_) => onTermination(null),
        ),
      );
      final hasPin = await stream.first;
      setState(() {
        _isVerified = !hasPin; // no PIN means allow immediately
        _isChecking = false;
      });
    } catch (error, stack) {
      logger.e('Failed to check PIN presence', error: error, stackTrace: stack);
      setState(() {
        _isChecking = false;
        _isVerified = true; // fallback: don't block user if check fails
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              CircularProgressIndicator(),
              SizedBox(height: 12),
              Text('Checking security...'),
            ],
          ),
        ),
      );
    }

    if (_isVerified) {
      return widget.child;
    }

    // PIN exists but not verified yet
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F9FC),
        body: PinVerifyView(
          appContext: widget.appContext,
          titleKey: 'pin-verify-title',
          subtitleKey: 'pin-verify-subtitle',
          onSuccess: (pin) => setState(() => _isVerified = true),
          fullScreen: true,
        ),
      ),
    );
  }
}
