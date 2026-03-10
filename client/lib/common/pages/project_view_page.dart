import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/models/project.dart';
import 'package:qfqq/common/providers/projects_provider.dart';
import 'package:qfqq/common/providers/users_provider.dart';
import 'package:qfqq/common/widgets/details_attribute_widget.dart';
import 'package:qfqq/common/widgets/projects/project_content_widget.dart';
import 'package:qfqq/common/widgets/projects/project_view_control.dart';
import 'package:qfqq/generated/l10n.dart';

class ProjectViewPage extends ConsumerWidget {
  final int projectId;
  const ProjectViewPage({super.key, required this.projectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = S.of(context);

    final project = ref.watch(projectProviderById(projectId));
    if (project == null) {
      return Center(child: Text(loc.projectNotFound));
    }

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          _buildTopCard(context, ref, project),
          const SizedBox(height: 16),

          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: SizedBox(
                    width: 250,
                    child: _buildMeetingInfo(context, ref, project),
                  ),
                ),

                const SizedBox(width: 16),

                // buildInfoCard(context, ref, project),
                // SizedBox(height: 16),
                Expanded(child: ProjectContentWidget(project: project)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeetingInfo(
    BuildContext context,
    WidgetRef ref,
    Project project,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(child: _buildDetails(context, ref, project)),
        const SizedBox(height: 16),
        Center(child: Card(child: ProjectViewControl(project: project))),
      ],
    );
  }

  Widget _buildTopCard(BuildContext context, WidgetRef ref, Project project) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                '${project.number}: ${project.title}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: theme.primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetails(BuildContext context, WidgetRef ref, Project project) {
    final loc = S.of(context);

    final supervisor = ref.watch(userByIdProvider(project.supervisorId));

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DetailsAttributeWidget(
            label: loc.attributeGoals,
            value: project.goals,
          ),
          DetailsAttributeWidget(
            label: loc.projectSupervisor,
            value: supervisor?.displayName ?? '',
          ),
        ],
      ),
    );
  }
}
