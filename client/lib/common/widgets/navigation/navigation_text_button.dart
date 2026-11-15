import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qfqq/common/providers/projects_provider.dart';

abstract class NavigationTextButton extends ConsumerWidget {
  
  void navigate(BuildContext context);
  String? getTitle(WidgetRef ref);

  const NavigationTextButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final title = getTitle(ref);
    if (title == null) {
      return SizedBox.shrink();
    }

    return TextButton(
      onPressed: () => navigate(context),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        minimumSize: Size.zero,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: theme.primaryColor,
            ),
          ),
          const SizedBox(width: 4),
          Transform.translate(
            offset: const Offset(0, 2),
            child: Icon(
              Icons.arrow_forward,
              size: 18,
              color: theme.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class ProjectNavigationTextButton extends NavigationTextButton {
  final int projectId;

  const ProjectNavigationTextButton({super.key, required this.projectId});

  @override
  void navigate(BuildContext context) => context.push('/projects/$projectId');

  @override
  String? getTitle(WidgetRef ref) => ref.watch(projectProviderById(projectId).select((p) => p?.title));
}
