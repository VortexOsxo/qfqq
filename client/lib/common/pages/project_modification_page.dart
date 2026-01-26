import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qfqq/common/models/project.dart';
import 'package:qfqq/common/providers/projects_provider.dart';
import 'package:qfqq/common/templates/page_template.dart';
import 'package:qfqq/common/widgets/reusables/user_text_field.dart';
import 'package:qfqq/generated/l10n.dart';

class ProjectModificationPage extends ConsumerWidget {
  final Project project;
  final bool isNewProject;

  ProjectModificationPage({super.key, Project? projectToModify})
    : project = projectToModify ?? Project.empty(),
      isNewProject = projectToModify == null;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<void> updateProject() async {
      final projectService = ref.read(projectsServiceProvider);
      if (isNewProject) {
        await projectService.createProject(project);
        context.go('/projects');
      } else {
        await projectService.updateProject(project);
        context.go('/project/${project.id}');
      }
    }

    final loc = S.of(context);

    const title = 'Project Creation';

    final content = Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                initialValue: project.title,
                onChanged: (value) => project.title = value,
                decoration: InputDecoration(
                  hintText: loc.projectCreationPageTitleHint,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              TextFormField(
                initialValue: project.goals,
                onChanged: (value) => project.goals = value,
                decoration: InputDecoration(
                  hintText: loc.projectCreationPageGoalsHint,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              UserTextField(
                label: loc.projectCreationPageSupervisorLabel,
                initialUserId: project.supervisorId,
                onSelected: (p0) => project.supervisorId = p0.id,
              ),
              const SizedBox(height: 20),

              FilledButton(
                onPressed: () => updateProject(),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  isNewProject
                      ? loc.projectCreationPageCreateProject
                      : loc.projectCreationPageUpdateProject,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return buildPageTemplate(context, content, title);
  }
}
