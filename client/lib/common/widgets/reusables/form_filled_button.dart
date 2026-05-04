import 'package:flutter/material.dart';

class FormFilledButton extends StatelessWidget {
  final String text;
  final bool isSending;
  final void Function()? onPressed;

  const FormFilledButton({
    super.key,
    required this.text,
    this.isSending = false,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: isSending
          ? const CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            )
          : Text(text),
    );
  }
}
