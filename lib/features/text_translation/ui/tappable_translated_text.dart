import 'package:flutter/material.dart';
import 'tappable_word.dart';

class TappableTranslatedText extends StatelessWidget {
  final String text;
  final TextStyle? style;

  const TappableTranslatedText({super.key, required this.text, this.style});

  @override
  Widget build(BuildContext context) {
    // Split the text into individual words
    final words = text.trim().split(RegExp(r'\s+'));

    // Wrap renders words in a flow — they wrap to the next line naturally
    return Wrap(
      // No spacing here because TappableWord adds its own trailing space
      children: words.map((word) {
        return TappableWord(word: word, style: style);
      }).toList(),
    );
  }
}
