import 'package:flutter/material.dart';
import 'package:qfqq/common/utils/get_status_ui.dart';
import 'package:qfqq/common/view_models/project_view_page_view_model.dart';
import 'package:qfqq/common/widgets/details_attribute_widget.dart';
import 'package:qfqq/common/widgets/status_chip.dart';
import 'package:qfqq/generated/l10n.dart';

class ProjectDescriptionWidget extends StatelessWidget {
  final ProjectViewPageViewModelState vm;
  final int padding;
  const ProjectDescriptionWidget({
    super.key,
    required this.vm,
    this.padding = 0,
  });

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);
    final project = vm.project!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StatusChip(
            statusUIData: getProjectStatusUI(S.of(context), vm.project!.status),
            alignement: Alignment.centerRight,
          ),
          SizedBox(height: 8),
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
