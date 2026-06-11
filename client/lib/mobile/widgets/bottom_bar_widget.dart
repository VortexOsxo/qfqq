import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qfqq/generated/l10n.dart';

class BottomBarWidget extends StatelessWidget {
  const BottomBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _BottomBarItem(icon: Icons.home, label: loc.homePageTitle, path: '/'),
          _BottomBarItem(icon: Icons.folder, label: loc.projectPageTitle, path: '/projects'),
          _BottomBarItem(icon: Icons.event_note, label: loc.agendasListPageTitle, path: '/agendas'),
          _BottomBarItem(icon: Icons.checklist, label: loc.decisionsListPageTitle, path: '/decisions'),
        ],
      ),
    );
  }
}

class _BottomBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String path;

  const _BottomBarItem({required this.icon, required this.label, required this.path});

  @override
  Widget build(BuildContext context) {
    final currentPath = GoRouterState.of(context).uri.path;
    final isActive =
        currentPath == path || (path != '/' && currentPath.startsWith(path));

    final activeColor = Theme.of(context).colorScheme.onPrimary;
    final inactiveColor = Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.75);
    return Padding(
      padding: const EdgeInsets.all(8),
      child: GestureDetector(
        onTap: () => context.go(path),
        child: Semantics(
          label: label,
          selected: isActive,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isActive ? activeColor : inactiveColor,
                size: 28,
              ),
              const SizedBox(height: 4),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 24,
                height: 3,
                decoration: BoxDecoration(
                  color: isActive ? activeColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
