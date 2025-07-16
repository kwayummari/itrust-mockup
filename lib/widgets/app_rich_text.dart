import 'package:flutter/material.dart';

// Make this class public by removing underscore
class TextPart {
  final String text;
  final Color color;
  final double fontSize;

  TextPart(this.text, this.color, this.fontSize);
}

class AppRichText extends StatelessWidget {
  final List<TextPart> parts;
  final TextAlign textAlign;
  final TextStyle? defaultStyle;

  const AppRichText({
    super.key,
    required this.parts,
    this.textAlign = TextAlign.start,
    this.defaultStyle,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: textAlign,
      text: TextSpan(
        style: defaultStyle ?? DefaultTextStyle.of(context).style,
        children: parts
            .map((part) =>
                TextSpan(text: part.text, style: TextStyle(color: part.color, fontSize: part.fontSize)))
            .toList(),
      ),
    );
  }
}
