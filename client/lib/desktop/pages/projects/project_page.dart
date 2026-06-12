import 'package:flutter/material.dart';
import 'package:qfqq/common/theme/styles.dart';
import 'package:qfqq/common/view_models/project_page_view_model.dart';
import 'package:qfqq/common/widgets/projects/project_list_widget.dart';
import 'package:qfqq/common/widgets/reusables/default_text_field.dart';
import 'package:qfqq/generated/l10n.dart';

class ProjectPage extends StatelessWidget {
  const ProjectPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ProjectPageViewModel(
      builder: (vm) => _ProjectPageView(vm: vm),
    );
  }
}

class _ProjectPageView extends StatelessWidget {
  final ProjectPageViewModelState vm;

  const _ProjectPageView({required this.vm});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSearchSection(context),
        Expanded(
          child: ProjectListWidget(
            projects: vm.filteredProjects,
            supervisorName: vm.supervisorName,
            onViewProject: vm.goToProject,
            showGoals: true,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            flex: 6,
            child: DefaultTextField(
              onChanged: vm.onSearchQueryChanged,
              hintText: S.of(context).searchTitleIdHint,
            ),
          ),
          Expanded(flex: 1, child: SizedBox()),
          ElevatedButton(
            onPressed: vm.goToProjectCreation,
            style: squareButtonStyle(context),
            child: Text(S.of(context).buttonCreateProject),
          ),
        ],
      ),
    );
  }
}
