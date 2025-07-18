import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/models/project.dart';
import 'package:qfqq/common/services/project_service.dart';
import 'package:qfqq/common/widgets/common_app_bar.dart';
import 'package:qfqq/common/widgets/default_text_field.dart';
import 'package:qfqq/generated/l10n.dart';

final projectsProvider = FutureProvider<List<Project>>((ref) async {
  final service = ref.read(projectServiceProvider);
  return await service.getProjects();
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
    final projectService = ref.read(projectServiceProvider);

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
          Expanded(child: _buildProjectsListAsync(projectService, ref)),
        ],
      ),
    );
  }

  Widget _buildProjectCreationForm(
    TextEditingController titleController,
    TextEditingController descriptionController,
    ProjectService projectService,
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

  Widget _buildProjectsListAsync(ProjectService projectService, WidgetRef ref) {
    var projectsAsync = ref.watch(projectsProvider);

    return projectsAsync.when(
      data: (projects) => _buildProjectsList(projects),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error: $error'),
      ),
    );
  }

  Widget _buildProjectsList(List<Project> projects) {
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
            onTap: () {},
          ),
        );
      },
    );
  }
}