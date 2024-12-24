import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isOutlined;
  final IconData? icon;
  final Color? color;
  final Color? textColor;
  final double padding;
  final double height; // New height property
  final double width;

  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isOutlined = false,
    this.icon,
    this.color,
    this.textColor,
    this.padding = 16.0,
    this.height = 48.0, // Default height
    this.width = double.infinity
  });

  @override
  Widget build(BuildContext context) {
    final buttonStyle = isOutlined
        ? OutlinedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: padding),
            side: BorderSide(color: color ?? const Color(0xFF0A5338)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          )
        : ElevatedButton.styleFrom(
            backgroundColor: color ?? const Color(0xFF0A5338),
            padding: EdgeInsets.symmetric(vertical: padding),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          );

    return SizedBox(
      width:  width,
      height: height, // Set button height here
      child: isOutlined
          ? OutlinedButton(
              style: buttonStyle,
              onPressed: onPressed,
              child: _buildContent(),
            )
          : ElevatedButton(
              style: buttonStyle,
              onPressed: onPressed,
              child: _buildContent(),
            ),
    );
  }

  Widget _buildContent() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) Icon(icon, color: textColor ?? Colors.white),
        if (icon != null) const SizedBox(width: 8.0), // Space between icon and text
        Text(
          label,
          style: TextStyle(
            color: isOutlined ? (textColor ?? const Color(0xFF0A5338)) : (textColor ?? Colors.white),
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
