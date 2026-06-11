import 'package:flutter/material.dart';
import 'package:qfqq/common/templates/card_template.dart';
import 'package:qfqq/common/theme/styles.dart';
import 'package:qfqq/common/view_models/project_page_view_model.dart';
import 'package:qfqq/common/widgets/empty_list_widget.dart';
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
        Expanded(child: _buildProjectsList(context)),
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

  Widget _buildProjectsList(BuildContext context) {
    final loc = S.of(context);
    final theme = Theme.of(context);
    final projects = vm.filteredProjects;

    if (projects.isEmpty) {
      Widget cardContent = EmptyListWidget(text: loc.projectPageEmpty);
      return buildContentListCardTemplate(cardContent);
    }

    Widget cardContent = Column(
      children: [
        Row(
          children: [
            SizedBox(width: 16),
            Expanded(flex: 1, child: Text(loc.attributeNumber)),
            Expanded(flex: 3, child: Text(loc.attributeTitle)),
            Expanded(flex: 7, child: Text(loc.attributeGoals)),
            Expanded(flex: 3, child: Text(loc.projectSupervisor)),
            Expanded(
              flex: 2,
              child: Align(
                alignment: Alignment.center,
                child: Text(S.of(context).commonAction),
              ),
            ),
            SizedBox(width: 16),
          ],
        ),
        Divider(color: theme.colorScheme.primary, thickness: 2,),
        Expanded(
          child: ListView.separated(
            itemCount: projects.length,
            separatorBuilder:
                (BuildContext context, int index) => const Divider(),
            itemBuilder: (context, index) {
              final project = projects[index];

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(width: 16),
                  Expanded(flex: 1, child: Text(project.number.toString())),
                  Expanded(flex: 3, child: Text(project.title)),
                  Expanded(flex: 7, child: Text(project.goals)),
                  Expanded(
                    flex: 3,
                    child: Text(
                      vm.supervisorName(
                        project.supervisorId,
                        loc.commonNoSupervisorSet,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Align(
                      alignment: Alignment.center,
                      child: TextButton(
                        style: inplaceTextButtonStyle(context),
                        onPressed: () => vm.goToProject(project.id),
                        child: Text(loc.agendaListView),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
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
