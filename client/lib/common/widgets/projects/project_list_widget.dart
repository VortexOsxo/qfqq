import 'package:flutter/material.dart';
import 'package:qfqq/common/models/project.dart';
import 'package:qfqq/common/templates/card_template.dart';
import 'package:qfqq/common/theme/styles.dart';
import 'package:qfqq/common/widgets/empty_list_widget.dart';
import 'package:qfqq/generated/l10n.dart';

class ProjectListWidget extends StatelessWidget {
  final List<Project> projects;
  final String Function(int supervisorId, String fallback) supervisorName;
  final void Function(int projectId) onViewProject;
  final bool showGoals;

  const ProjectListWidget({
    super.key,
    required this.projects,
    required this.supervisorName,
    required this.onViewProject,
    this.showGoals = true,
  });

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);
    final theme = Theme.of(context);

    if (projects.isEmpty) {
      return buildContentListCardTemplate(
        EmptyListWidget(text: loc.projectPageEmpty),
      );
    }

    Widget cardContent = Column(
      children: [
        Row(
          children: [
            const SizedBox(width: 16),
            Expanded(flex: 1, child: Text(loc.attributeNumber)),
            Expanded(flex: 3, child: Text(loc.attributeTitle)),
            if (showGoals) Expanded(flex: 7, child: Text(loc.attributeGoals)),
            Expanded(flex: 3, child: Text(loc.projectSupervisor)),
            Expanded(
              flex: 2,
              child: Align(
                alignment: Alignment.center,
                child: Text(loc.commonAction),
              ),
            ),
            const SizedBox(width: 16),
          ],
        ),
        Divider(color: theme.colorScheme.primary, thickness: 2),
        Expanded(
          child: ListView.separated(
            itemCount: projects.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final project = projects[index];

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const SizedBox(width: 16),
                  Expanded(flex: 1, child: Text(project.number.toString())),
                  Expanded(flex: 3, child: Text(project.title)),
                  if (showGoals) Expanded(flex: 7, child: Text(project.goals)),
                  Expanded(
                    flex: 3,
                    child: Text(
                      supervisorName(project.supervisorId, loc.commonNoSupervisorSet),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Align(
                      alignment: Alignment.center,
                      child: TextButton(
                        style: inplaceTextButtonStyle(context),
                        onPressed: () => onViewProject(project.id),
                        child: Text(loc.agendaListView),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
              );
            },
          ),
        ),
      ],
    );

    return buildContentListCardTemplate(cardContent);
  }
}
