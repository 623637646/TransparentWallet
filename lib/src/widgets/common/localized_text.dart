import 'package:flutter/material.dart';
import 'rust_stream_builder.dart';

class LocalizedText extends StatelessWidget {
  final String textId;
  final TextStyle? style;
  final TextAlign? textAlign;
  final Map<String, String>? args;

  const LocalizedText(
    this.textId, {
    super.key,
    this.style,
    this.textAlign,
    this.args,
  });

  @override
  Widget build(BuildContext context) {
    return RustStreamBuilder<String, String>(
      keys: [textId, args],
      initialData: '',
      subscriptionBuilder: (rustContext, onNext, onTermination) {
        return rustContext.lookUpText(
          textId: textId,
          args: args,
          onNext: onNext,
          onTermination: onTermination,
        );
      },
      builder: (context, text) {
        return Text(text, style: style, textAlign: textAlign);
      },
    );
  }
}
