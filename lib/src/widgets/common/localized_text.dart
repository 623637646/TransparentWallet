import 'dart:async';
import 'package:flutter/material.dart';
import '../../rust/api/context.dart';
import '../../rust/utils/bridge_helper.dart';

class LocalizedText extends StatefulWidget {
  final String textId;
  final Context appContext;
  final TextStyle? style;
  final TextAlign? textAlign;
  final Map<String, String>? args;

  const LocalizedText(
    this.textId, {
    super.key,
    required this.appContext,
    this.style,
    this.textAlign,
    this.args,
  });

  @override
  State<LocalizedText> createState() => _LocalizedTextState();
}

class _LocalizedTextState extends State<LocalizedText> {
  String _text = '';
  BridgeSubscription? _subscription;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _subscribe();
  }

  @override
  void didUpdateWidget(LocalizedText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.textId != widget.textId || oldWidget.args != widget.args) {
      _resubscribe();
    }
  }

  @override
  void dispose() {
    _unsubscribe();
    super.dispose();
  }

  Future<void> _subscribe() async {
    void onNext(String value) {
      if (mounted) {
        setState(() {
          _text = value;
          _initialized = true;
        });
      }
    }

    void onTermination(String? value) {
      // Stream terminated
    }

    if (widget.args != null) {
      _subscription = await widget.appContext.lookupLocalWithArgs(
        textId: widget.textId,
        args: widget.args!,
        onNext: onNext,
        onTermination: onTermination,
      );
    } else {
      _subscription = await widget.appContext.lookupLocal(
        textId: widget.textId,
        onNext: onNext,
        onTermination: onTermination,
      );
    }
  }

  void _unsubscribe() {
    _subscription?.dispose();
    _subscription = null;
  }

  Future<void> _resubscribe() async {
    _unsubscribe();
    await _subscribe();
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return Text('', style: widget.style);
    }
    return Text(_text, style: widget.style, textAlign: widget.textAlign);
  }
}
