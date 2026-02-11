import 'dart:async';
import 'package:flutter/material.dart';
import '../../rust/api/context.dart';
import '../../utils/bridge_helper.dart';

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
  late Stream<String> _stream;

  @override
  void initState() {
    super.initState();
    _initStream();
  }

  void _initStream() {
    _stream = convertSubscriptionToStream<String, String>((
      onNext,
      onTermination,
    ) {
      if (widget.args != null) {
        return widget.appContext.lookupLocalWithArgs(
          textId: widget.textId,
          args: widget.args!,
          onNext: onNext,
          onTermination: onTermination,
        );
      } else {
        return widget.appContext.lookupLocal(
          textId: widget.textId,
          onNext: onNext,
          onTermination: onTermination,
        );
      }
    });
  }

  @override
  void didUpdateWidget(LocalizedText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.textId != widget.textId ||
        !_mapEquals(oldWidget.args, widget.args)) {
      setState(() {
        _initStream();
      });
    }
  }

  bool _mapEquals(Map? a, Map? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (final key in a.keys) {
      if (b[key] != a[key]) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String>(
      stream: _stream,
      builder: (context, snapshot) {
        final text = snapshot.data ?? '';
        return Text(text, style: widget.style, textAlign: widget.textAlign);
      },
    );
  }
}
