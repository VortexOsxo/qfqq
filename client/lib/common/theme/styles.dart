import 'package:flutter/material.dart';

// Buttons

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

ButtonStyle squareButtonStyleSmall(BuildContext context) {
  return squareButtonStyle(context).copyWith(
    padding: WidgetStateProperty.all(EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
    textStyle: WidgetStateProperty.all(
      TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
    ),
  );
}

ButtonStyle inplaceTextButtonStyle(BuildContext context) {
  return TextButton.styleFrom(padding: EdgeInsets.zero);
}
