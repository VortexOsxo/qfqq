import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qfqq/common/models/errors/project_errors.dart';
import 'package:qfqq/common/models/project.dart';
import 'package:qfqq/common/providers/projects_provider.dart';
import 'package:qfqq/common/services/modal_service.dart';
import 'package:qfqq/common/templates/navigation_guard.dart';
import 'package:qfqq/common/utils/validation.dart';
import 'package:qfqq/common/widgets/reusables/form_filled_button.dart';
import 'package:qfqq/common/widgets/reusables/form_outlined_button.dart';
import 'package:qfqq/common/widgets/reusables/default_text_field.dart';
import 'package:qfqq/common/widgets/reusables/selection_text_fields/user_text_field.dart';
import 'package:qfqq/generated/l10n.dart';

class ProjectModificationPage extends ConsumerStatefulWidget {
  final Project project;
  final bool isNewProject;

  ProjectModificationPage({super.key, Project? projectToModify})
    : project = projectToModify ?? Project.empty(),
      isNewProject = projectToModify == null;

  @override
  ConsumerState<ProjectModificationPage> createState() =>
      _ProjectModificationState();
}

class _ProjectModificationState extends ConsumerState<ProjectModificationPage> {
  ProjectErrors errors = ProjectErrors();
  bool isSending = false;
  late Project originalProject;

  Future<bool> shouldPop(BuildContext context) async {
    if (originalProject == widget.project) {
      return true;
    }
    final loc = S.of(context);
    return await ModalService.showConfirmation(
      context,
      title: loc.unsavedChangesTitle,
      message: loc.unsavedChangesMessage,
      confirmLabel: loc.unsavedChangesDiscard,
      cancelLabel: loc.unsavedChangesKeepEditing,
    );
  }

  Future<void> updateProject() async {
    var projectsError = validateProject(widget.project);
    if (projectsError.hasAny()) {
      setState(() => errors = projectsError);
      return;
    }

    setState(() => isSending = true);
    final projectService = ref.read(projectsServiceProvider);
    final serverErrors =
        widget.isNewProject
            ? await projectService.createProject(widget.project)
            : await projectService.updateProject(widget.project);

    setState(() => isSending = false);
    if (serverErrors.hasAny()) {
      setState(() => errors = serverErrors);
      return;
    }

    goBack();
  }

  void goBack() {
    if (!mounted) {
      return;
    }

    activeNavigationGuard = null;
    context.go(
      widget.isNewProject ? '/projects' : '/project/${widget.project.id}',
    );
  }

  @override
  void initState() {
    super.initState();
    originalProject = widget.project.copy();
    activeNavigationGuard = shouldPop;
  }

  @override
  void dispose() {
    activeNavigationGuard = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DefaultTextField(
                initialValue: widget.project.title,
                hintText: loc.projectCreationPageTitleHint,
                onChanged: (value) => widget.project.title = value,
                error: errors.titleError,
              ),
              const SizedBox(height: 20),

              DefaultTextField(
                initialValue: widget.project.goals,
                hintText: loc.projectCreationPageGoalsHint,
                onChanged: (value) => widget.project.goals = value,
                error: errors.goalsError,
                maxLines: 5,
              ),
              const SizedBox(height: 20),

              UserTextField(
                label: loc.projectCreationPageSupervisorLabel,
                initialUserId: widget.project.supervisorId,
                onSelected: (p0) => widget.project.supervisorId = p0.id,
                error: errors.supervisorError,
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  FormOutlinedButton(text: loc.commonCancel, onPressed: goBack),

                  const SizedBox(width: 12),
                  FormFilledButton(
                    text:
                        widget.isNewProject
                            ? loc.projectCreationPageCreateProject
                            : loc.projectCreationPageUpdateProject,
                    isSending: isSending,
                    onPressed: () => updateProject(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
