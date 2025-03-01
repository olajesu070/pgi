import 'package:flutter/material.dart';

class BadgeUI extends StatelessWidget {
  final String text;
  final String cssClass;

  const BadgeUI({super.key, required this.text, required this.cssClass});

  @override
  Widget build(BuildContext context) {
    final Map<String, BoxDecoration> styles = {
      'userBanner--primary': BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(20),
      ),
      'userBanner--lightGreen': BoxDecoration(
        color: Colors.lightGreen,
        borderRadius: BorderRadius.circular(20),
      ),
      'userBanner--boardMember': BoxDecoration(
        color: Colors.purple,
        borderRadius: BorderRadius.circular(20),
      ),
      'userBanner--siteCrew': BoxDecoration(
        color: Colors.orange,
        borderRadius: BorderRadius.circular(20),
      ),
      'userBanner--silver': BoxDecoration(
        color: Colors.grey[400],
        borderRadius: BorderRadius.circular(20),
      ),
      'userBanner--fireMed': BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(20),
      ),
      'userBanner--safety': BoxDecoration(
        color: Colors.teal,
        borderRadius: BorderRadius.circular(20),
      ),
      'userBanner--grandmaster': BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.yellow, Colors.red],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      // Default style
      'default': BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.circular(20),
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: styles[cssClass] ?? styles['default'],
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }
}
