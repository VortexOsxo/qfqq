import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qfqq/common/models/project.dart';
import 'package:qfqq/common/providers/projects_provider.dart';
import 'package:qfqq/common/templates/page_template.dart';
import 'package:qfqq/common/theme/styles.dart';
import 'package:qfqq/common/widgets/default_text_field.dart';
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
    final loc = S.of(context);

    String title = loc.projectPageTitle;
    Widget content = _buildProjectsListAsync(context, ref);
    return buildPageTemplate(context, content, title);
  }

  Widget _buildProjectsListAsync(BuildContext context, WidgetRef ref) {
    var projects = ref.watch(filteredProjectProvider);

    var projectLists = ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: projects.length,
      itemBuilder: (context, index) {
        final project = projects[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: Text(
              '${project.number} - ${project.title}',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(project.goals),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              context.go('/project/${project.id}');
            },
          ),
        );
      },
    );

    return Column(
      children: [
        Padding(
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
        ),
        SizedBox(height: 16),
        Expanded(child: projectLists),
      ],
    );
  }
}
