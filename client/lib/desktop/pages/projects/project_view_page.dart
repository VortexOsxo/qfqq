import 'package:flutter/material.dart';
import 'package:qfqq/common/view_models/project_view_page_view_model.dart';
import 'package:qfqq/common/widgets/details_attribute_widget.dart';
import 'package:qfqq/common/widgets/projects/project_content_widget.dart';
import 'package:qfqq/desktop/widgets/projects/project_view_control.dart';
import 'package:qfqq/generated/l10n.dart';

class ProjectViewPage extends StatelessWidget {
  final int projectId;
  const ProjectViewPage({super.key, required this.projectId});

  @override
  Widget build(BuildContext context) {
    return ProjectViewPageViewModel(
      projectId: projectId,
      builder: (vm) => _ProjectViewPageView(vm: vm),
    );
  }
}

class _ProjectViewPageView extends StatelessWidget {
  final ProjectViewPageViewModelState vm;

  const _ProjectViewPageView({required this.vm});

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);
    final project = vm.project;

    if (project == null) {
      return Center(child: Text(loc.projectNotFound));
    }

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          _buildTopCard(context),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: SizedBox(
                    width: 250,
                    child: _buildProjectInfo(context),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(child: ProjectContentWidget(project: project)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopCard(BuildContext context) {
    final theme = Theme.of(context);
    final project = vm.project!;

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
    );
  }

  Widget _buildProjectInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(child: _buildDetails(context)),
        const SizedBox(height: 16),
        Center(child: ProjectViewControl(vm: vm)),
      ],
    );
  }

  Widget _buildDetails(BuildContext context) {
    final loc = S.of(context);
    final project = vm.project!;

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
            value: vm.supervisorName,
          ),
        ],
      ),
    );
  }
}
