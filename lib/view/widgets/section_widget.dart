// lib/view/widgets/section_widget.dart
import 'package:flutter/material.dart';

class SectionWidget extends StatelessWidget {
  final String title;
  final String actionText;
  final Widget content;

  const SectionWidget({
    required this.title,
    required this.actionText,
    required this.content,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(actionText, style: const TextStyle(color: Color(0xFF747688))),
            ],
          ),
        ),
        content,
      ],
    );
  }
}
