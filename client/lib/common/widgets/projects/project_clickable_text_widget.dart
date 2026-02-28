import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qfqq/common/providers/projects_provider.dart';
import 'package:qfqq/common/theme/styles.dart';
import 'package:qfqq/common/utils/is_id_valid.dart';
import 'package:qfqq/generated/l10n.dart';

class ProjectClickableTextWidget extends ConsumerWidget {
  final int? projectId;

  const ProjectClickableTextWidget({super.key, required this.projectId});

  void navigateToProject(BuildContext context) {
    context.go('/project/$projectId');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = S.of(context);
    final project =
        isIdValid(projectId)
            ? ref.watch(projectProviderById(projectId!))
            : null;
    if (project == null) return Text(loc.commonNoProjectSet);
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton(
        onPressed: () => navigateToProject(context),
        style: inplaceTextButtonStyle(context),
        child: Text(project.title),
      ),
    );
  }
}
