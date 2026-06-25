import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qfqq/common/services/auth_service.dart';
import 'package:qfqq/common/widgets/common_app_bar.dart';
import 'package:qfqq/generated/l10n.dart';

class MobileShell extends ConsumerWidget {
  final Widget child;
  final String? title;

  const MobileShell({required this.child, this.title, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permissions = ref.watch(
      authStateProvider.select((s) => s.permissions),
    );
    final currentPath = GoRouterState.of(context).uri.path;

    final destinations = [
      _NavDestination(Icons.home, '', '/'),
      _NavDestination(Icons.folder_outlined, '', '/projects'),
      _NavDestination(Icons.calendar_today_outlined, '', '/agendas'),
      _NavDestination(Icons.gavel_outlined, '', '/decisions'),
      if (permissions?.canUpdatePermissions == true)
        _NavDestination(Icons.shield_outlined, '', '/permissions'),
    ];

    int selectedIndex = destinations.indexWhere(
      (d) => currentPath == d.path || (d.path != '/' && currentPath.startsWith(d.path)),
    );
    if (selectedIndex < 0) selectedIndex = 0;

    return Scaffold(
      appBar: CommonAppBar(title: title ?? 'QFQQ'),
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (i) => context.go(destinations[i].path),
        destinations: destinations
            .map((d) => NavigationDestination(icon: Icon(d.icon), label: d.label))
            .toList(),
      ),
    );
  }
}

class _NavDestination {
  final IconData icon;
  final String label;
  final String path;
  const _NavDestination(this.icon, this.label, this.path);
}
