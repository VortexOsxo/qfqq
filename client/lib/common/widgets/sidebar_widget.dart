import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qfqq/common/services/auth_service.dart';
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
          Spacer(),
          _LogOutButton()
        ],
      ),
    );
  }
}

class HoverTextButton extends StatefulWidget {
  final String text;
  final VoidCallback onTap;

  const HoverTextButton({
    required this.text,
    required this.onTap,
    super.key,
  });

  @override
  State<HoverTextButton> createState() => _HoverTextButtonState();
}

class _HoverTextButtonState extends State<HoverTextButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovering = true),
        onExit: (_) => setState(() => _hovering = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: widget.onTap,
          child: Text(
            widget.text,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
              fontSize: 18,
              fontWeight:
                  _hovering ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}

class _LogOutButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return HoverTextButton(
      text: S.of(context).profilePageLogout,
      onTap: () {
        ref.read(authStateProvider.notifier).logout();
        context.go('/login');
      },
    );
  }
}

class _SideBarItem extends StatelessWidget {
  final String title;
  final String path;

  const _SideBarItem({
    required this.title,
    required this.path,
  });

  @override
  Widget build(BuildContext context) {
    return HoverTextButton(
      text: title,
      onTap: () => context.go(path),
    );
  }
}
