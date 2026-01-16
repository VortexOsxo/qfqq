import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qfqq/common/models/project.dart';
import 'package:qfqq/common/providers/projects_provider.dart';
import 'package:qfqq/common/services/projects_service.dart';
import 'package:qfqq/common/templates/page_template.dart';
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

class ProjectPage extends ConsumerStatefulWidget {
  const ProjectPage({super.key});

  @override
  ConsumerState<ProjectPage> createState() => _ProjectPageState();
}

class _ProjectPageState extends ConsumerState<ProjectPage> {
  late final TextEditingController titleController;
  late final TextEditingController descriptionController;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController();
    descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final projectService = ref.read(projectsServiceProvider);
    final loc = S.of(context);

    String title = loc.projectPageTitle;
    Widget content = Row(
      children: [
        SizedBox(
          width: 300, // Fixed width to prevent unbounded width issues
          child: _buildProjectCreationForm(projectService, loc),
        ),
        const SizedBox(width: 32),
        _buildProjectsListAsync(context, ref),
      ],
    );
    return buildPageTemplate(context, content, title);
  }

  Widget _buildProjectCreationForm(ProjectsService projectService, S loc) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(loc.projectPageCreateNewProject, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 10),
          DefaultTextField(
            controller: titleController,
            hintText: loc.projectPageTitleHint,
          ),
          const SizedBox(height: 10),
          DefaultTextField(
            controller: descriptionController,
            hintText: loc.projectPageDescriptionHint,
            maxLines: 3,
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () async {
              await projectService.createProject(
                title: titleController.text,
                description: descriptionController.text,
              );
              // Clear the fields after creating
              titleController.clear();
              descriptionController.clear();
            },
            child: Text(loc.projectPageCreateButton),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectsListAsync(BuildContext context, WidgetRef ref) {
    var projects = ref.watch(filteredProjectProvider);
    return _buildProjectsList(context, projects);
  }

  Widget _buildProjectsList(BuildContext context, List<Project> projects) {
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
              project.title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(project.description),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              context.go('/project/${project.id}');
            },
          ),
        );
      },
    );

    return Expanded(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: DefaultTextField(
              onChanged:
                  (value) =>
                      ref.read(projectSearchQueryProvider.notifier).state =
                          value,
              hintText: S.of(context).projectPageSearchHint,
            ),
          ),
          SizedBox(height: 16),
          Expanded(child: projectLists),
        ],
      ),
    );
  }
}
