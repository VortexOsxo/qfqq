import 'package:flutter/material.dart';

ButtonStyle squareButtonStyle(BuildContext context) {
  final theme = Theme.of(context);

  return ElevatedButton.styleFrom(
    backgroundColor: theme.primaryColor,
    foregroundColor: Colors.white,
    elevation: 8,
    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
  );
}
