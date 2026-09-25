import 'package:flutter/material.dart';

class RefreshButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isRefreshing;
  final String tooltip;

  const RefreshButton({
    super.key,
    required this.onPressed,
    required this.isRefreshing,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return IconButton(
      style: IconButton.styleFrom(
        minimumSize: Size.zero,
        padding: EdgeInsets.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      tooltip: tooltip,
      onPressed: isRefreshing ? null : onPressed,
      icon:
          isRefreshing
              ? const SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
              : Icon(Icons.refresh, color: theme.colorScheme.primary, size: 25),
    );
  }
}

Widget stackRefreshButton(
  Widget child,
  void Function() onPressed,
  bool isRefreshing,
  String label,
) {
  return Stack(
    alignment: Alignment.center,
    clipBehavior: Clip.none,
    children: [
      child,
      Positioned(
        right: 8,
        top: -4,
        child: RefreshButton(
          onPressed: onPressed,
          isRefreshing: isRefreshing,
          tooltip: label,
        ),
      ),
    ],
  );
}
