import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qfqq/common/providers/router_provider.dart';
import 'package:qfqq/common/services/auth_service.dart';
import 'package:qfqq/common/utils/platform.dart';
import 'package:qfqq/generated/l10n.dart';

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showLeadingButton;

  const CommonAppBar({
    super.key,
    required this.title,
    this.showLeadingButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final length = platformType == PlatformType.mobile ? 100.0 : 80.0;

    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.primary,
      leading: showLeadingButton ? _LeadingButton() : null,
      leadingWidth: length,
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

class _LeadingButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.read(routerProvider);

    final homeButton = IconButton(
      icon: const Icon(Icons.home),
      onPressed: () => context.go('/'),
      tooltip: S.of(context).commonTooltipHome,
      color: Theme.of(context).colorScheme.onPrimary,
    );

    final backButton = IconButton(
      icon: const Icon(Icons.chevron_left),
      onPressed: router.canPop() ? () => router.pop() : null,
      tooltip: S.of(context).commonBack,
      color: Theme.of(context).colorScheme.onPrimary,
    );

    return Row(children: [homeButton, backButton]);
  }
}

class _ProfileLink extends ConsumerWidget {
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    if (authState.user == null) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => context.push('/profile'),
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
          Icon(Icons.person, color: Theme.of(context).colorScheme.onPrimary),
        ],
      ),
    );
  }
}
