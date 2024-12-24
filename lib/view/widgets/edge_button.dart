// lib/view/widgets/edge_button.dart
import 'package:flutter/material.dart';

class EdgeButton extends StatelessWidget {
  final Color color;
  final String text;

  const EdgeButton({required this.color, required this.text, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 39,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 10),
        ),
      ),
    );
  }
}
