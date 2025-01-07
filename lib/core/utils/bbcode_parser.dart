import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class BBCodeParser {
  // Method to convert BBCode to a list of formatted TextSpans
  static List<TextSpan> parseBBCode(String message) {
    final List<TextSpan> spans = [];
    final regex = RegExp(
      r'(\[b\](.*?)\[/b\])|(\[i\](.*?)\[/i\])|(\[u\](.*?)\[/u\])|(\[QUOTE.*?\](.*?)\[/QUOTE\])|(\[USER=\d+\](.*?)\[/USER\])|(\[url=(.*?)\](.*?)\[/url\])',
      dotAll: true,
    );

    int lastIndex = 0;

    for (final match in regex.allMatches(message)) {
      // Add text before match as a normal span
      if (match.start > lastIndex) {
        spans.add(TextSpan(text: message.substring(lastIndex, match.start)));
      }

      // Handle BBCode tags
      if (match.group(1) != null) {
        // Bold
        spans.add(TextSpan(
          text: match.group(2),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ));
      } else if (match.group(3) != null) {
        // Italic
        spans.add(TextSpan(
          text: match.group(4),
          style: const TextStyle(fontStyle: FontStyle.italic),
        ));
      } else if (match.group(5) != null) {
        // Underline
        spans.add(TextSpan(
          text: match.group(6),
          style: const TextStyle(decoration: TextDecoration.underline),
        ));
      } else if (match.group(7) != null) {
        // Quote
        spans.add(TextSpan(
          text: match.group(8),
          style: const TextStyle(
            fontStyle: FontStyle.italic,
            color: Colors.grey,
          ),
        ));
      } else if (match.group(9) != null) {
        // User mention
        spans.add(TextSpan(
          text: '@${match.group(10)}',
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
        ));
      } else if (match.group(11) != null) {
        // URL link
        spans.add(TextSpan(
          text: match.group(12),
          style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
          recognizer: TapGestureRecognizer()..onTap = () => print('Open URL: ${match.group(11)}'),
        ));
      }

      lastIndex = match.end;
    }

    // Add remaining text
    if (lastIndex < message.length) {
      spans.add(TextSpan(text: message.substring(lastIndex)));
    }

    return spans;
  }
}
