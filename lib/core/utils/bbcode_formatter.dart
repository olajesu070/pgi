class BBCodeFormatter {
  static final RegExp _urlRegex = RegExp(
    r'((https?|ftp)://[^\s/$.?#].[^\s]*)',
    caseSensitive: false,
  ); // URL regex pattern

  static final RegExp _boldRegex = RegExp(r'\*\*(.*?)\*\*'); // **bold** syntax
  static final RegExp _italicRegex = RegExp(r'\*(.*?)\*');   // *italic* syntax

  static final Map<String, String> _emojiMap = {
    ':)': '😊',
    ':(': '☹️',
    ':D': '😄',
    ';)': '😉',
    ':P': '😛',
    'B)': '😎',
    ':o': '😮',
  }; // Emoji replacements

  /// Formats the provided message by converting markdown-like syntax and emojis into BBCode.
  static String formatMessageWithBBCode(String message) {
    message = _replaceUrls(message);
    message = _replaceBoldText(message);
    message = _replaceItalicText(message);
    message = _replaceEmojis(message);
    return message;
  }

  /// Private helper to replace URLs with BBCode.
  static String _replaceUrls(String message) {
    return message.replaceAllMapped(_urlRegex, (match) {
      final url = match.group(0);
      return '[url]$url[/url]';
    });
  }

  /// Private helper to replace **bold** text with BBCode.
  static String _replaceBoldText(String message) {
    return message.replaceAllMapped(_boldRegex, (match) {
      final boldText = match.group(1);
      return '[b]$boldText[/b]';
    });
  }

  /// Private helper to replace *italic* text with BBCode.
  static String _replaceItalicText(String message) {
    return message.replaceAllMapped(_italicRegex, (match) {
      final italicText = match.group(1);
      return '[i]$italicText[/i]';
    });
  }

  /// Private helper to replace text-based emojis with Unicode emojis.
  static String _replaceEmojis(String message) {
    _emojiMap.forEach((shortcut, emoji) {
      message = message.replaceAll(shortcut, emoji);
    });
    return message;
  }
}
