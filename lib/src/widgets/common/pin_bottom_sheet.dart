import 'dart:async';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../rust/api/pin.dart';
import '../../utils/app_context.dart';
import '../../utils/design_tokens.dart';
import 'localized_text.dart';
import 'toast.dart';

enum PinBottomSheetMode { create, modify, verify }

enum PinStep {
  createEnterNew,
  createConfirmNew,
  modifyEnterOld,
  verifyEnterCurrent,
}

class PinBottomSheet extends ConsumerStatefulWidget {
  final PinBottomSheetMode mode;

  const PinBottomSheet({super.key, required this.mode});

  static Future<bool?> show(
    BuildContext context, {
    required PinBottomSheetMode mode,
  }) {
    final tokens = DesignTheme.of(context);
    return showModalBottomSheet<bool>(
      context: context,
      backgroundColor: tokens.colors.canvasParchment,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(DesignTokens.rounded.lg.topLeft.x),
          topRight: Radius.circular(DesignTokens.rounded.lg.topRight.x),
        ),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: PinBottomSheet(mode: mode),
      ),
    );
  }

  @override
  ConsumerState<PinBottomSheet> createState() => _PinBottomSheetState();
}

class _PinBottomSheetState extends ConsumerState<PinBottomSheet> {
  late PinStep _step;
  final List<int> _firstPin = [];
  final List<int> _oldPin = [];
  final List<int> _currentInput = [];
  String? _errorMessage;
  Map<String, String>? _errorArgs;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    switch (widget.mode) {
      case PinBottomSheetMode.create:
        _step = PinStep.createEnterNew;
        break;
      case PinBottomSheetMode.modify:
        _step = PinStep.modifyEnterOld;
        break;
      case PinBottomSheetMode.verify:
        _step = PinStep.verifyEnterCurrent;
        break;
    }
  }

  void _onKeyTap(int digit) {
    if (_isProcessing) return;
    if (_currentInput.length < 6) {
      setState(() {
        _errorMessage = null;
        _errorArgs = null;
        _currentInput.add(digit);
      });
      if (_currentInput.length == 6) {
        _onSubmit();
      }
    }
  }

  void _onBackspace() {
    if (_isProcessing) return;
    if (_currentInput.isNotEmpty) {
      setState(() {
        _errorMessage = null;
        _errorArgs = null;
        _currentInput.removeLast();
      });
    }
  }

  Future<void> _onSubmit() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      switch (_step) {
        case PinStep.createEnterNew:
          _firstPin.clear();
          _firstPin.addAll(_currentInput);
          setState(() {
            _currentInput.clear();
            _step = PinStep.createConfirmNew;
          });
          break;

        case PinStep.createConfirmNew:
          if (const ListEquality<int>().equals(_firstPin, _currentInput)) {
            final appContext = ref.appContext;
            if (widget.mode == PinBottomSheetMode.modify) {
              final result = await appContext.updatePin(
                oldPin: _oldPin,
                newPin: _currentInput,
              );
              if (result is PinResult_Ok) {
                if (mounted) {
                  Toast.show(context, 'pin-modify-success');
                  Navigator.of(context).pop(true);
                }
              } else if (result is PinResult_Error) {
                setState(() {
                  _errorMessage = 'pin-incorrect';
                  _errorArgs = {'attempts': result.field0.toString()};
                  _currentInput.clear();
                  _step = PinStep.modifyEnterOld;
                });
              }
            } else {
              await appContext.createPin(pin: _currentInput);
              if (mounted) {
                Toast.show(context, 'pin-create-success');
                Navigator.of(context).pop(true);
              }
            }
          } else {
            setState(() {
              _errorMessage = 'pin-mismatch';
              _currentInput.clear();
              _step = PinStep.createEnterNew;
            });
          }
          break;

        case PinStep.modifyEnterOld:
          final appContext = ref.appContext;
          final result = await appContext.verifyPin(pin: _currentInput);
          if (result is PinResult_Ok) {
            _oldPin.clear();
            _oldPin.addAll(_currentInput);
            setState(() {
              _currentInput.clear();
              _step = PinStep.createEnterNew;
            });
          } else if (result is PinResult_Error) {
            setState(() {
              _errorMessage = 'pin-incorrect';
              _errorArgs = {'attempts': result.field0.toString()};
              _currentInput.clear();
            });
          }
          break;

        case PinStep.verifyEnterCurrent:
          final appContext = ref.appContext;
          final result = await appContext.verifyPin(pin: _currentInput);
          if (result is PinResult_Ok) {
            if (mounted) {
              Toast.show(context, 'pin-verify-success');
              Navigator.of(context).pop(true);
            }
          } else if (result is PinResult_Error) {
            setState(() {
              _errorMessage = 'pin-incorrect';
              _errorArgs = {'attempts': result.field0.toString()};
              _currentInput.clear();
            });
          }
          break;
      }
    } catch (e) {
      debugPrint("PIN operation failure: $e");
      setState(() {
        _errorMessage = 'pin-incorrect';
        _currentInput.clear();
      });
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  String _getPromptKey() {
    switch (_step) {
      case PinStep.createEnterNew:
        return 'pin-enter-new';
      case PinStep.createConfirmNew:
        return 'pin-confirm-new';
      case PinStep.modifyEnterOld:
        return 'pin-enter-old';
      case PinStep.verifyEnterCurrent:
        return 'pin-enter-current';
    }
  }

  Widget _buildKeyRow(List<dynamic> keys) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: keys.map<Widget>((keyVal) {
        if (keyVal == null) {
          return const Expanded(child: SizedBox.shrink());
        }
        return Expanded(child: Center(child: _buildKeyButton(keyVal)));
      }).toList(),
    );
  }

  Widget _buildKeyButton(dynamic keyVal) {
    final tokens = DesignTheme.of(context);
    final isBackspace = keyVal is IconData;

    return Container(
      margin: EdgeInsets.all(DesignTokens.spacing.xs),
      width: 68.0,
      height: 68.0,
      decoration: BoxDecoration(
        color: tokens.colors.surfaceTile1,
        shape: BoxShape.circle,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: isBackspace ? _onBackspace : () => _onKeyTap(keyVal as int),
          child: Center(
            child: isBackspace
                ? Icon(keyVal, color: tokens.colors.ink, size: 24.0)
                : Text(
                    keyVal.toString(),
                    style: DesignTokens.typography.lead.copyWith(
                      color: tokens.colors.ink,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildPinIndicators() {
    final tokens = DesignTheme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(6, (index) {
        final isActive = index < _currentInput.length;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: EdgeInsets.symmetric(horizontal: DesignTokens.spacing.xs),
          width: 14.0,
          height: 14.0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? tokens.colors.primary : Colors.transparent,
            border: Border.all(
              color: isActive ? tokens.colors.primary : tokens.colors.bodyMuted,
              width: 2.0,
            ),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = DesignTheme.of(context);

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          Container(
            margin: EdgeInsets.symmetric(vertical: DesignTokens.spacing.xs),
            width: 36.0,
            height: 4.0,
            decoration: BoxDecoration(
              color: tokens.colors.bodyMuted.withValues(alpha: 0.3),
              borderRadius: DesignTokens.rounded.pill,
            ),
          ),

          SizedBox(height: DesignTokens.spacing.md),

          // Header Prompt Text
          Padding(
            padding: EdgeInsets.symmetric(horizontal: DesignTokens.spacing.lg),
            child: LocalizedText(
              _getPromptKey(),
              style: DesignTokens.typography.bodyStrong.copyWith(
                color: tokens.colors.ink,
              ),
            ),
          ),

          SizedBox(height: DesignTokens.spacing.lg),

          // Pin Dots Indicators
          _buildPinIndicators(),

          SizedBox(height: DesignTokens.spacing.md),

          // Error Message Placeholder/Display
          SizedBox(
            height: 24.0,
            child: _errorMessage != null
                ? LocalizedText(
                    _errorMessage!,
                    args: _errorArgs,
                    style: DesignTokens.typography.caption.copyWith(
                      color: const Color(0xFFFF385C),
                      fontWeight: FontWeight.w500,
                    ),
                  )
                : (_isProcessing
                      ? SizedBox(
                          width: 16.0,
                          height: 16.0,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.0,
                            color: tokens.colors.primary,
                          ),
                        )
                      : const SizedBox.shrink()),
          ),

          SizedBox(height: DesignTokens.spacing.md),

          // Custom Keyboard Grid
          Padding(
            padding: EdgeInsets.symmetric(horizontal: DesignTokens.spacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildKeyRow([1, 2, 3]),
                SizedBox(height: DesignTokens.spacing.xs),
                _buildKeyRow([4, 5, 6]),
                SizedBox(height: DesignTokens.spacing.xs),
                _buildKeyRow([7, 8, 9]),
                SizedBox(height: DesignTokens.spacing.xs),
                _buildKeyRow([null, 0, Icons.backspace_outlined]),
                SizedBox(height: DesignTokens.spacing.md),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
