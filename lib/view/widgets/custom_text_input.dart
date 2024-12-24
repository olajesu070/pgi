import 'package:flutter/material.dart';

class CustomTextInput extends StatefulWidget {
  final String hintText;
  final IconData? leftIcon;
  final bool isPassword;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final int? maxLines;

  const CustomTextInput({
    super.key,
    required this.hintText,
    this.leftIcon,
    this.isPassword = false,
    this.controller,
    this.onChanged,
    this.validator,
    this.maxLines,
  });

  @override
  _CustomTextInputState createState() => _CustomTextInputState();
}

class _CustomTextInputState extends State<CustomTextInput> {
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: widget.isPassword && !_isPasswordVisible,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: const TextStyle(color: Colors.grey),
        prefixIcon: Icon(
          widget.leftIcon,
          color: const Color(0xFFE4DFDF),
        ),
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(color: Color(0xFFE4DFDF)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(color: Color(0xFFE4DFDF)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(color: Color(0xFF0A5338)),
        ),
        filled: true,
        fillColor: Colors.transparent,
      ),
      onChanged: widget.onChanged,
      validator: widget.validator,
      maxLines: widget.isPassword ? 1 : widget.maxLines, // Conditional maxLines
    );
  }
}
