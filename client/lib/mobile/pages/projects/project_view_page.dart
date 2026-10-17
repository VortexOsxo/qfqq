import 'package:flutter/material.dart';
import 'package:qfqq/common/models/permissions.dart';
import 'package:qfqq/common/utils/get_status_ui.dart';
import 'package:qfqq/common/view_models/project_view_page_view_model.dart';
import 'package:qfqq/common/widgets/details_attribute_widget.dart';
import 'package:qfqq/common/widgets/permission_required.dart';
import 'package:qfqq/common/widgets/projects/project_content_widget.dart';
import 'package:qfqq/mobile/widgets/title_with_status.dart';
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTopCard(context),
        const SizedBox(height: 16),
        _buildDetails(context),
        Expanded(child: ProjectContentWidget(project: project)),
      ],
    );
  }

  Widget _buildTopCard(BuildContext context) {
    final project = vm.project!;
    final statusUIData = getProjectStatusUI(S.of(context), project.status);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: TitleWithStatus(
              title: '${project.number}: ${project.title}',
              uiData: statusUIData,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetails(BuildContext context) {
    final loc = S.of(context);
    final project = vm.project!;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
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
            Spacer(),
            if (vm.canMarkAsCompleted())
              PermissionRequired(
                neededPermissions: Permissions(contribute: true),
                child: TextButton(
                  onPressed: vm.markAsCompleted,
                  child: Text(loc.projectViewPageCloseProject),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
