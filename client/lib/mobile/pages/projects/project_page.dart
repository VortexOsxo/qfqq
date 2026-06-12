import 'package:flutter/material.dart';
import 'package:qfqq/common/view_models/project_page_view_model.dart';
import 'package:qfqq/common/widgets/projects/project_list_widget.dart';
import 'package:qfqq/common/widgets/reusables/default_text_field.dart';
import 'package:qfqq/generated/l10n.dart';

class ProjectPage extends StatelessWidget {
  const ProjectPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ProjectPageViewModel(builder: (vm) => _ProjectPageView(vm: vm));
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
            showGoals: false,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: DefaultTextField(
        onChanged: vm.onSearchQueryChanged,
        hintText: S.of(context).searchTitleIdHint,
      ),
    );
  }
}
