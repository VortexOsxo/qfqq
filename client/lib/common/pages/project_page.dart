import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qfqq/common/models/project.dart';
import 'package:qfqq/common/providers/projects_provider.dart';
import 'package:qfqq/common/providers/users_provider.dart';
import 'package:qfqq/common/templates/card_template.dart';
import 'package:qfqq/common/theme/styles.dart';
import 'package:qfqq/common/utils/is_id_valid.dart';
import 'package:qfqq/common/widgets/empty_list_widget.dart';
import 'package:qfqq/common/widgets/reusables/default_text_field.dart';
import 'package:qfqq/generated/l10n.dart';

final projectSearchQueryProvider = StateProvider<String>((ref) => '');

final filteredProjectProvider = Provider<List<Project>>((ref) {
  var projects = ref.watch(projectsProvider);
  var query = ref.watch(projectSearchQueryProvider);

  if (query.isEmpty) return projects;

  return projects
      .where(
        (project) => project.title.toLowerCase().contains(query.toLowerCase()),
      )
      .toList();
});

class ProjectPage extends ConsumerWidget {
  const ProjectPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _buildProjectsListAsync(context, ref);
  }

  Widget _buildProjectsListAsync(BuildContext context, WidgetRef ref) {
    var projects = ref.watch(filteredProjectProvider);

    return Column(
      children: [
        _buildSearchSection(context, ref),
        Expanded(child: _buildProjectsList(context, ref, projects)),
      ],
    );
  }

  Widget _buildSearchSection(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            flex: 6,
            child: DefaultTextField(
              onChanged:
                  (value) =>
                      ref.read(projectSearchQueryProvider.notifier).state =
                          value,
              hintText: S.of(context).projectPageSearchHint,
            ),
          ),
          Expanded(flex: 1, child: SizedBox()),
          ElevatedButton(
            onPressed: () => context.go('/project/creation'),
            style: squareButtonStyle(context),
            child: Text(S.of(context).buttonCreateProject),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectsList(
    BuildContext context,
    WidgetRef ref,
    List<Project> projects,
  ) {
    final loc = S.of(context);
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
        const Divider(),
        Expanded(
          child: ListView.separated(
            itemCount: projects.length,
            separatorBuilder:
                (BuildContext context, int index) => const Divider(),
            itemBuilder: (context, index) {
              final project = projects[index];
              final supervisor =
                  isIdValid(project.supervisorId)
                      ? ref.watch(userByIdProvider(project.supervisorId))
                      : null;

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
                      supervisor != null
                          ? supervisor.username
                          : loc.commonNoSupervisorSet,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Align(
                      alignment: Alignment.center,
                      child: TextButton(
                        style: inplaceTextButtonStyle(context),
                        child: Text(loc.agendaListView),
                        onPressed: () => context.go('/project/${project.id}'),
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
