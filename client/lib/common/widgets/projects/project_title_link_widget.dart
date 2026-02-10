import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qfqq/common/providers/projects_provider.dart';
import 'package:qfqq/generated/l10n.dart';

class ProjectTitleLinkWidget extends ConsumerWidget {
  final int projectId;

  const ProjectTitleLinkWidget({super.key, required this.projectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = S.of(context);
    final theme = Theme.of(context);

    final project = ref.watch(projectProviderById(projectId));
    if (project == null) {
      return Text(loc.projectNotFound);
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          '${loc.commonProject}: ',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        Text(
          project.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: theme.primaryColor,
          ),
        ),
        const SizedBox(width: 6),
        IconButton(
          onPressed: () => context.go('/project/$projectId'),
          icon: Icon(
            Icons.open_in_new,
            size: 24,
            color: theme.primaryColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
