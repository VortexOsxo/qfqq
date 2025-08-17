import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showHomeButton;

  const CommonAppBar({
    super.key,
    required this.title,
    this.showHomeButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.primary,
      leading:
          showHomeButton
              ? IconButton(
                icon: const Icon(Icons.home),
                onPressed: () => context.go('/'),
                tooltip: 'Home',
                color: Theme.of(context).colorScheme.onPrimary,
              )
              : null,
      title: Text(
        title,
        style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
