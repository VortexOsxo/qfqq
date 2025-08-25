import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qfqq/common/models/project.dart';
import 'package:qfqq/common/providers/projects_provider.dart';
import 'package:qfqq/common/services/projects_service.dart';
import 'package:qfqq/common/widgets/common_app_bar.dart';
import 'package:qfqq/common/widgets/default_text_field.dart';
import 'package:qfqq/generated/l10n.dart';

class ProjectListPage extends ConsumerStatefulWidget {
  const ProjectListPage({super.key});

  @override
  ConsumerState<ProjectListPage> createState() => _ProjectPageState();
}

class _ProjectPageState extends ConsumerState<ProjectListPage> {
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

    return Scaffold(
      appBar: CommonAppBar(title: S.of(context).homePageTitle),
      body: Row(
        children: [
          SizedBox(
            width: 300, // Fixed width to prevent unbounded width issues
            child: _buildProjectCreationForm(
              titleController,
              descriptionController,
              projectService,
            ),
          ),
          const SizedBox(width: 32),
          Expanded(child: _buildProjectsListAsync(context, ref)),
        ],
      ),
    );
  }

  Widget _buildProjectCreationForm(
    TextEditingController titleController,
    TextEditingController descriptionController,
    ProjectsService projectService,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Project Page'),
          const SizedBox(height: 10),
          DefaultTextField(
            controller: titleController,
            hintText: 'Enter a project title',
          ),
          const SizedBox(height: 10),
          DefaultTextField(
            controller: descriptionController,
            hintText: 'Enter a project description',
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
              // Refresh the projects list
              ref.invalidate(projectsProvider);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectsListAsync(BuildContext context, WidgetRef ref) {
    var projects = ref.watch(projectsProvider);
    return  _buildProjectsList(context, projects);
  }

  Widget _buildProjectsList(BuildContext context, List<Project> projects) {
    return ListView.builder(
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
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(project.description),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () { context.go('/project/${project.id}'); },
          ),
        );
      },
    );
  }
}