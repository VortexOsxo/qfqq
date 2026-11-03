import 'package:flutter/material.dart';

class NavigationArrowIcon extends StatelessWidget {
  final String tooltip;
  final VoidCallback onPressed;

  const NavigationArrowIcon({
    super.key,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      visualDensity: const VisualDensity(horizontal: -4),
      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
      padding: EdgeInsets.zero,
      icon: Icon(
        Icons.arrow_forward,
        size: 16,
        color: Theme.of(context).colorScheme.primary,
      ),
      onPressed: onPressed,
    );
  }
}
