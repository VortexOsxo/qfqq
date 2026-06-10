import 'package:flutter/material.dart';

class DefaultTextField extends StatelessWidget {
  final String? initialValue;
  final String? hintText;
  final ValueChanged<String>? onChanged;
  final int maxLines;
  final String? error;
  final TextEditingController? controller;

  const DefaultTextField({
    super.key,
    this.initialValue,
    this.hintText,
    this.onChanged,
    this.maxLines = 1,
    this.error,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      initialValue: controller == null ? initialValue : null,
      onChanged: onChanged,
      maxLines: maxLines,

      decoration: InputDecoration(
        hintText: hintText,
        errorText: error,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }
}