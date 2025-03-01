import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class BBCodeParser {
  // BBCode to Flutter TextSpan Parser
  static List<InlineSpan> parseBBCode(String message) {
    final List<InlineSpan> spans = [];
    final regex = RegExp(
      r'(\[b\](.*?)\[/b\])|' // Bold
      r'(\[i\](.*?)\[/i\])|' // Italic
      r'(\[u\](.*?)\[/u\])|' // Underline
      r'(\[quote.*?\](.*?)\[/quote\])|' // Quote
      r'(\[user=\d+\](.*?)\[/user\])|' // User mention
      r'(\[url=(.*?)\](.*?)\[/url\])|' // URL with text
      r'(\[url\](.*?)\[/url\])|' // URL without text
      r'(\[LIST\](.*?)\[/LIST\])|' // Unordered List
      r'(\[LIST=1\](.*?)\[/LIST\])|' // Ordered List
      r'(\[IMG.*?\](.*?)\[/IMG\])|' // Image
      r'(\[EMAIL.*?\](.*?)\[/EMAIL\])|' // Email
      r'(\[CENTER.*?\](.*?)\[/CENTER\])|' // Center
      r'(\[ATTACH.*?\](.*?)\[/ATTACH\])', // Attachment
      caseSensitive: false,
      dotAll: true,
    );

    // Emoji mapping
    final emojiMap = {
      ':)': '😊',
      ';)': '😉',
      ':(': '😞',
      ':mad:': '😡',
      ':confused:': '😕',
      ':cool:': '😎',
      ':p': '😛',
    };

    // Replace emoji codes
    emojiMap.forEach((code, emoji) {
      message = message.replaceAll(code, emoji);
    });

    int lastIndex = 0;

    for (final match in regex.allMatches(message)) {
      if (match.start > lastIndex) {
        spans.add(TextSpan(text: message.substring(lastIndex, match.start)));
      }

      if (match.group(1) != null) {
        spans.add(TextSpan(
            text: match.group(2) ?? '',
            style: const TextStyle(fontWeight: FontWeight.bold)));
      } else if (match.group(3) != null) {
        spans.add(TextSpan(
            text: match.group(4) ?? '',
            style: const TextStyle(fontStyle: FontStyle.italic)));
      } else if (match.group(5) != null) {
        spans.add(TextSpan(
            text: match.group(6) ?? '',
            style: const TextStyle(decoration: TextDecoration.underline)));
      } else if (match.group(7) != null) {
        spans.add(TextSpan(
            text: match.group(8) ?? '',
            style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)));
      } else if (match.group(9) != null) {
        spans.add(TextSpan(
            text: match.group(10) ?? '',
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)));
      } else if (match.group(11) != null) {
        final url = match.group(12)?.trim();
        final linkText = match.group(13)?.trim() ?? url ?? 'Invalid URL';

        spans.add(TextSpan(
          text: linkText,
          style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              if (url != null) {
                _launchURL(url);
              }
            },
        ));
      } else if (match.group(14) != null) {
        final linkText = match.group(15);
        if (linkText != null) {
          spans.add(TextSpan(
            text: linkText,
            style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
            recognizer: TapGestureRecognizer()
              ..onTap = () => _launchURL(linkText),
          ));
        }
      } else if (match.group(16) != null) {
        // Unordered List
        final listItems = match.group(17)?.split('[*]').where((item) => item.trim().isNotEmpty) ?? [];
        for (var item in listItems) {
          spans.add(WidgetSpan(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("• ", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF000000))),
                Expanded(child: Text(item.trim())),
              ],
            ),
          ));
        }
      } else if (match.group(18) != null) {
        // Ordered List
        final listItems = match.group(19)?.split('[*]').where((item) => item.trim().isNotEmpty).toList() ?? [];
        for (var i = 0; i < listItems.length; i++) {
          spans.add(WidgetSpan(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("${i + 1}. ", style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF000000))),
                Expanded(child: Text(listItems[i].trim())),
              ],
            ),
          ));
        }
      } else if (match.group(20) != null) {
        // Image
        final imageUrl = match.group(21);
        if (imageUrl != null) {
          spans.add(WidgetSpan(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Image.network(imageUrl, width: 100, height: 100),
            ),
          ));
        }
      } else if (match.group(22) != null) {
        // Email
        final email = match.group(23);
        if (email != null) {
          spans.add(TextSpan(
            text: email,
            style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
            recognizer: TapGestureRecognizer()
              ..onTap = () => _launchURL('mailto:$email'),
          ));
        }
      } else if (match.group(24) != null) {
        // Center
        final centeredText = match.group(25);
        if (centeredText != null) {
          spans.add(WidgetSpan(
            child: Center(
              child: Text(centeredText, textAlign: TextAlign.center),
            ),
          ));
        }
      } else if (match.group(26) != null) {
        // Attachment
        final attachmentId = match.group(27);
        if (attachmentId != null) {
          spans.add(WidgetSpan(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text("📎 Attachment: $attachmentId", style: const TextStyle(color: Colors.blue)),
            ),
          ));
        }
      }

      lastIndex = match.end;
    }

    if (lastIndex < message.length) {
      spans.add(TextSpan(text: message.substring(lastIndex)));
    }

    return spans;
  }

  static Future<void> _launchURL(String url) async {
    final Uri? uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('Could not launch URL: $url');
    }
  }
}
