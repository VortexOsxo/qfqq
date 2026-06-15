import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qfqq/common/models/project.dart';
import 'package:qfqq/common/providers/projects_provider.dart';
import 'package:qfqq/common/providers/users_provider.dart';
import 'package:qfqq/common/services/modal_service.dart';
import 'package:qfqq/generated/l10n.dart';

class ProjectViewPageViewModel extends ConsumerStatefulWidget {
  final int projectId;
  final Widget Function(ProjectViewPageViewModelState vm) builder;

  const ProjectViewPageViewModel({
    super.key,
    required this.projectId,
    required this.builder,
  });

  @override
  ConsumerState<ProjectViewPageViewModel> createState() => ProjectViewPageViewModelState();
}

class ProjectViewPageViewModelState extends ConsumerState<ProjectViewPageViewModel> {
  Project? get project => ref.watch(projectProviderById(widget.projectId));

  String get supervisorName =>
      ref.watch(userByIdProvider(project?.supervisorId ?? 0))?.displayName ?? '';

  void goToModify() => context.go('/projects/creation', extra: project);

  void goBackToProjects() => context.go('/projects');

  Future<void> deleteProject() async {
    final loc = S.of(context);

    final confirmed = await ModalService.showConfirmation(
      context: context,
      title: loc.projectDeleteTitle,
      message: loc.projectDeleteMessage,
      confirmLabel: loc.projectDeleteConfirm,
      cancelLabel: loc.commonCancel,
    );

    if (!confirmed) return;

    final success = await ref
        .read(projectsServiceProvider)
        .deleteProject(widget.projectId);

    if (context.mounted && success) goBackToProjects();
  }

  @override
  Widget build(BuildContext context) => widget.builder(this);
}
