import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qfqq/generated/l10n.dart';

class SidebarWidget extends StatelessWidget {
  const SidebarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);
    return Container(
      width: 250,
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _SideBarItem(title: loc.homePageTitle, path: '/'),
          _SideBarItem(title: loc.projectPageTitle, path: '/projects'),
          _SideBarItem(title: loc.agendasListPageTitle, path: '/agendas'),
          _SideBarItem(title: loc.decisionsListPageTitle, path: '/decisions'),
          _SideBarItem(title: loc.profilePageTitle, path: '/profile'),
        ],
      ),
    );
  }
}

class _SideBarItem extends StatefulWidget {
  final String title;
  final String path;

  const _SideBarItem({required this.title, required this.path});

  @override
  State<StatefulWidget> createState() => _SideBarItemState();
}

class _SideBarItemState extends State<_SideBarItem> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovering = true),
        onExit: (_) => setState(() => _hovering = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () {
            context.go(widget.path);
          },
          child: Text(
            widget.title,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
              fontSize: 18,
              fontWeight: _hovering ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
