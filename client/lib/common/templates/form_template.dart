import 'package:flutter/material.dart';

Widget buildLabel(BuildContext context, String text) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: Text(
      text,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        fontWeight: FontWeight.w500,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: .7),
      ),
    ),
  );
}

Widget buildDivider(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 24.0),
    child: Divider(
      color: Theme.of(context).colorScheme.outline.withValues(alpha: .2),
    ),
  );
}
