import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qfqq/common/services/auth_service.dart';
import 'package:qfqq/generated/l10n.dart';

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
    final loc = S.of(context);
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.primary,
      leading:
          showHomeButton
              ? IconButton(
                icon: const Icon(Icons.home),
                onPressed: () => context.go('/'),
                tooltip: loc.commonTooltipHome,
                color: Theme.of(context).colorScheme.onPrimary,
              )
              : null,
      title: Text(
        title,
        style: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontSize: 18),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: _ProfileLink(),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _ProfileLink extends ConsumerStatefulWidget {
  @override
  ConsumerState<_ProfileLink> createState() => _ProfileLinkState();
}

class _ProfileLinkState extends ConsumerState<_ProfileLink> {
  @override
  Widget build(BuildContext context) {
    final authState = ref.read(authStateProvider);
    if (authState.user == null) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => context.go('/profile'),
      child: Row(
        children: [
          Text(
            authState.user?.displayName ?? S.of(context).commonProfile,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
              fontSize: 18,
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.person, color: Colors.white),
        ],
      ),
    );
  }
}
