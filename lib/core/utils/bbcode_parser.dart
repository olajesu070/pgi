import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class BBCodeParser {
  // Method to convert BBCode to a list of formatted TextSpans
  static List<TextSpan> parseBBCode(String message) {
    final List<TextSpan> spans = [];
    final regex = RegExp(
      r'(\[b\](.*?)\[/b\])|(\[i\](.*?)\[/i\])|(\[u\](.*?)\[/u\])|(\[quote.*?\](.*?)\[/quote\])|(\[user=\d+\](.*?)\[/user\])|(\[url=(.*?)\](.*?)\[/url\])',
      caseSensitive: false,  // Handles both upper and lower case BBCode
      dotAll: true,
    );

    int lastIndex = 0;

    for (final match in regex.allMatches(message)) {
      if (match.start > lastIndex) {
        spans.add(TextSpan(text: message.substring(lastIndex, match.start)));
      }

      if (match.group(1) != null) {
        spans.add(TextSpan(text: match.group(2), style: const TextStyle(fontWeight: FontWeight.bold)));
      } else if (match.group(3) != null) {
        spans.add(TextSpan(text: match.group(4), style: const TextStyle(fontStyle: FontStyle.italic)));
      } else if (match.group(5) != null) {
        spans.add(TextSpan(text: match.group(6), style: const TextStyle(decoration: TextDecoration.underline)));
      } else if (match.group(7) != null) {
        spans.add(TextSpan(text: match.group(8), style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)));
      } else if (match.group(9) != null) {
        spans.add(TextSpan(text: match.group(10), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)));
      } else if (match.group(11) != null) {
        final url = match.group(11)?.trim();
        final linkText = match.group(12)?.trim() ?? url;
        spans.add(TextSpan(
          text: linkText,
          style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
          recognizer: TapGestureRecognizer()..onTap = () => _launchURL(url!),
        ));
      }

      lastIndex = match.end;
    }

    if (lastIndex < message.length) {
      spans.add(TextSpan(text: message.substring(lastIndex)));
    }

    return spans;
  }

  static Future<void> _launchURL(String url) async {

    // Regular expression to capture the URL inside [url=...]
    RegExp regExp = RegExp(r'\[url=(.*?)\]');
    Match? match = regExp.firstMatch(url);

    if (match != null) {
      final uri = Uri.tryParse(match.group(1)!);
      if (uri != null && await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        debugPrint('Could not launch URL: $match');
      }
    }
  }
}


