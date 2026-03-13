import 'dart:convert';
import 'package:flutter/material.dart';
import '../../rust/api/app_mode.dart';
import '../../rust/api/context.dart';
import '../../utils/device_secret.dart';
import 'localized_text.dart';

Future<String?> showPinInputSheet({
  required BuildContext context,
  required Context appContext,
  required String titleKey,
  required String subtitleKey,
  String? confirmSubtitleKey,
  bool needsConfirmation = false,
  VoidCallback? onDelete,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        color: Color(0xFFF2F2F7),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: PinInputView(
        appContext: appContext,
        titleKey: titleKey,
        subtitleKey: subtitleKey,
        confirmSubtitleKey: confirmSubtitleKey,
        needsConfirmation: needsConfirmation,
        onCompleted: (pin) => Navigator.of(context).pop(pin),
        onCancel: () => Navigator.of(context).pop(),
        onDelete: onDelete,
        showCancel: true,
        fullScreen: false,
      ),
    ),
  );
}

class PinInputView extends StatefulWidget {
  const PinInputView({
    super.key,
    required this.appContext,
    required this.titleKey,
    required this.subtitleKey,
    required this.onCompleted,
    this.onCancel,
    this.showCancel = false,
    this.fullScreen = false,
    this.isBusy = false,
    this.errorTextKey,
    this.resetCounter = 0,
    this.onDelete,
    this.needsConfirmation = false,
    this.confirmSubtitleKey,
    this.errorArgs,
  });

  final Context appContext;
  final String titleKey;
  final String subtitleKey;
  final String? confirmSubtitleKey;
  final bool needsConfirmation;
  final void Function(String pin) onCompleted;
  final VoidCallback? onCancel;
  final VoidCallback? onDelete;
  final bool showCancel;
  final bool fullScreen;
  final bool isBusy;
  final String? errorTextKey;
  final Map<String, String>? errorArgs;
  final int resetCounter;

  @override
  State<PinInputView> createState() => _PinInputViewState();
}

class _PinInputViewState extends State<PinInputView> {
  String _pin = '';
  String _firstPin = '';
  bool _isConfirming = false;
  String? _internalErrorKey;
  static const int _pinLength = 6;

  @override
  void didUpdateWidget(covariant PinInputView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.resetCounter != widget.resetCounter) {
      _pin = '';
      _firstPin = '';
      _isConfirming = false;
      _internalErrorKey = null;
    }
  }

  void _onKeyPress(String key) {
    if (widget.isBusy) return;
    if (_pin.length < _pinLength) {
      setState(() {
        _pin += key;
        _internalErrorKey = null;
      });
      if (_pin.length == _pinLength) {
        // give a small delay to show the last dot filled
        Future.delayed(const Duration(milliseconds: 150), () {
          if (!mounted) return;
          if (widget.needsConfirmation && !_isConfirming) {
            setState(() {
              _firstPin = _pin;
              _pin = '';
              _isConfirming = true;
            });
          } else if (widget.needsConfirmation && _isConfirming) {
            if (_pin == _firstPin) {
              widget.onCompleted(_pin);
            } else {
              setState(() {
                _pin = '';
                _firstPin = '';
                _isConfirming = false;
                _internalErrorKey = 'err-pin-mismatch';
              });
            }
          } else {
            widget.onCompleted(_pin);
          }
        });
      }
    }
  }

  void _onBackspace() {
    if (widget.isBusy) return;
    if (_pin.isNotEmpty) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 60), // Placeholder to center title
              Expanded(
                child: LocalizedText(
                  widget.titleKey,
                  appContext: widget.appContext,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
              SizedBox(
                width: 60,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: widget.showCancel
                      ? GestureDetector(
                          onTap: widget.onCancel,
                          child: LocalizedText(
                            'btn-cancel',
                            appContext: widget.appContext,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: widget.fullScreen ? 80 : 40),

        // Subtitle
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: LocalizedText(
            _isConfirming
                ? (widget.confirmSubtitleKey ?? widget.subtitleKey)
                : widget.subtitleKey,
            appContext: widget.appContext,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ),
        const SizedBox(height: 24),

        // Pin Indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_pinLength, (index) {
            final isFilled = index < _pin.length;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 6),
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isFilled ? Colors.black87 : Colors.black12,
              ),
            );
          }),
        ),

        if (widget.errorTextKey != null || _internalErrorKey != null) ...[
          const SizedBox(height: 16),
          LocalizedText(
            _internalErrorKey ?? widget.errorTextKey!,
            appContext: widget.appContext,
            args: _internalErrorKey != null ? null : widget.errorArgs,
            style: const TextStyle(
              color: Colors.redAccent,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],

        const Spacer(),

        // Keypad
        Padding(
          padding: const EdgeInsets.only(bottom: 60),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [_buildKey('1'), _buildKey('2'), _buildKey('3')],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [_buildKey('4'), _buildKey('5'), _buildKey('6')],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [_buildKey('7'), _buildKey('8'), _buildKey('9')],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    width: 76,
                    height: 76,
                    child: widget.onDelete != null
                        ? Center(
                            child: GestureDetector(
                              onTap: widget.onDelete,
                              child: const Icon(
                                Icons.help_outline,
                                color: Colors.black54,
                                size: 28,
                              ),
                            ),
                          )
                        : null,
                  ),
                  _buildKey('0'),
                  _buildBackspace(),
                ],
              ),
            ],
          ),
        ),
      ],
    );

    if (widget.fullScreen) {
      content = SafeArea(child: content);
    }

    return Container(
      height:
          widget.fullScreen ? null : MediaQuery.of(context).size.height * 0.9,
      color: widget.fullScreen ? null : const Color(0xFFF2F2F7),
      child: content,
    );
  }

  Widget _buildKey(String value) {
    return GestureDetector(
      onTap: () => _onKeyPress(value),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 76,
        height: 76,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.black.withValues(alpha: 0.05),
            width: 1,
          ),
          color: Colors.white.withValues(
            alpha: 0.5,
          ), // Subtle transparent white for key bg
        ),
        alignment: Alignment.center,
        child: Text(
          value,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w400,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildBackspace() {
    return GestureDetector(
      onTap: _onBackspace,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 76,
        height: 76,
        alignment: Alignment.center,
        child: const Icon(
          Icons.backspace_outlined,
          size: 26,
          color: Colors.black54,
        ),
      ),
    );
  }
}

Future<String?> showPinVerifySheet({
  required BuildContext context,
  required Context appContext,
  String titleKey = 'pin-verify-title',
  String subtitleKey = 'pin-verify-subtitle',
}) async {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => PinVerifyView(
      appContext: appContext,
      titleKey: titleKey,
      subtitleKey: subtitleKey,
      onSuccess: (pin) => Navigator.of(context).pop(pin),
      onCancel: () => Navigator.of(context).pop(),
    ),
  );
}

class PinVerifyView extends StatefulWidget {
  const PinVerifyView({
    super.key,
    required this.appContext,
    required this.titleKey,
    required this.subtitleKey,
    required this.onSuccess,
    this.onCancel,
    this.fullScreen = false,
  });

  final Context appContext;
  final String titleKey;
  final String subtitleKey;
  final void Function(String pin) onSuccess;
  final VoidCallback? onCancel;
  final bool fullScreen;

  @override
  State<PinVerifyView> createState() => _PinVerifyViewState();
}

class _PinVerifyViewState extends State<PinVerifyView> {
  bool _isVerifying = false;
  int _resetCounter = 0;
  String? _errorKey;
  Map<String, String>? _errorArgs;
  int _attemptsRemaining = 5;

  Future<void> _verifyPin(String pin) async {
    setState(() {
      _isVerifying = true;
      _errorKey = null;
    });

    try {
      final deviceSecret = await DeviceSecretManager.getDeviceSecretBytes();
      final ok = await widget.appContext.verifyPin(
        pin: utf8.encode(pin),
        deviceSecret: deviceSecret,
      );

      if (!mounted) return;

      if (ok) {
        widget.onSuccess(pin);
      } else {
        _handleFailedAttempt();
      }
    } catch (error) {
      if (!mounted) return;
      _handleFailedAttempt();
    }
  }

  void _handleFailedAttempt() {
    setState(() {
      _attemptsRemaining--;
      if (_attemptsRemaining > 0) {
        _errorKey =
            _attemptsRemaining == 1 ? 'pin-last-attempt' : 'pin-attempts-left';
        _errorArgs = {'attempts': _attemptsRemaining.toString()};
      }
      _isVerifying = false;
      _resetCounter++;
    });

    if (_attemptsRemaining == 0) {
      _deletePinDirectly();
    }
  }

  Future<void> _deletePinDirectly() async {
    try {
      await widget.appContext.deletePin();
      await widget.appContext.setAppMode(appMode: AppMode.init);
    } catch (e) {
      // log error
    }
  }

  Future<void> _onDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: LocalizedText(
          'pin-reset-confirm-title',
          appContext: widget.appContext,
        ),
        content: LocalizedText(
          'pin-reset-confirm-msg',
          appContext: widget.appContext,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: LocalizedText('btn-cancel', appContext: widget.appContext),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: LocalizedText(
              'btn-delete',
              appContext: widget.appContext,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _deletePinDirectly();
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = PinInputView(
      appContext: widget.appContext,
      titleKey: widget.titleKey,
      subtitleKey: widget.subtitleKey,
      onCompleted: _verifyPin,
      onDelete: _onDelete,
      onCancel: widget.onCancel,
      showCancel: widget.onCancel != null,
      isBusy: _isVerifying,
      errorTextKey: _errorKey,
      errorArgs: _errorArgs,
      resetCounter: _resetCounter,
      fullScreen: widget.fullScreen,
    );

    if (widget.fullScreen) {
      return content;
    }

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        color: Color(0xFFF2F2F7),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: content,
    );
  }
}
