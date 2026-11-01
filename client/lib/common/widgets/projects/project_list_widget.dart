import 'package:flutter/material.dart';
import 'package:qfqq/common/models/project.dart';
import 'package:qfqq/common/templates/card_template.dart';
import 'package:qfqq/common/theme/styles.dart';
import 'package:qfqq/common/utils/platform.dart';
import 'package:qfqq/common/utils/text.dart';
import 'package:qfqq/common/widgets/empty_list_widget.dart';
import 'package:qfqq/common/widgets/mobile_list_action_button.dart';
import 'package:qfqq/common/widgets/reusables/refresh_button.dart';
import 'package:qfqq/generated/l10n.dart';

class ProjectListWidget extends StatelessWidget {
  final List<Project> projects;
  final String Function(int supervisorId, String fallback) supervisorName;
  final void Function(int projectId) onViewProject;
  final VoidCallback onRefresh;
  final bool isRefreshing;
  final bool showGoals;

  const ProjectListWidget({
    super.key,
    required this.projects,
    required this.supervisorName,
    required this.onViewProject,
    required this.onRefresh,
    required this.isRefreshing,
    this.showGoals = true,
  });

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);
    final theme = Theme.of(context);

    if (projects.isEmpty) {
      Widget cardContent = stackRefreshButton(
        EmptyListWidget(text: loc.projectPageEmpty),
        onRefresh,
        isRefreshing,
        loc.refreshProjects,
      );
      return buildContentListCardTemplate(cardContent);
    }

    Widget listCardContent = Column(
      children: [
        Row(
          children: [
            const SizedBox(width: 16),
            SizedBox(width: 40, child: Text(loc.attributeNumber)),
            Expanded(flex: 3, child: Text(loc.attributeTitle)),
            const SizedBox(width: 8),
            if (showGoals) Expanded(flex: 7, child: Text(loc.attributeGoals)),
            Expanded(flex: 2, child: Text(loc.projectSupervisor)),
            SizedBox(
              width: platformType == PlatformType.mobile ? 48 : 80,
              child:
                  platformType == PlatformType.mobile
                      ? const SizedBox()
                      : Align(
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
                children: [
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 40,
                    child: listText(project.number.toString()),
                  ),
                  Expanded(flex: 3, child: listText(project.title, maxLines: 2)),
                  const SizedBox(width: 8),
                  if (showGoals) Expanded(flex: 7, child: listText(project.goals, maxLines: 2)),
                  Expanded(
                    flex: 2,
                    child: Text(
                      supervisorName(project.supervisorId, loc.commonNoSupervisorSet),
                    ),
                  ),
                  SizedBox(
                    width: platformType == PlatformType.mobile ? 48 : 80,
                    child: Align(
                      alignment: Alignment.center,
                      child:
                          platformType == PlatformType.mobile
                              ? MobileListActionButton(
                                tooltip: loc.agendaListView,
                                onPressed: () => onViewProject(project.id),
                              )
                              : TextButton(
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

    Widget cardContent = stackRefreshButton(
      listCardContent,
      onRefresh,
      isRefreshing,
      loc.refreshProjects,
    );
    return buildContentListCardTemplate(cardContent);
  }
}
