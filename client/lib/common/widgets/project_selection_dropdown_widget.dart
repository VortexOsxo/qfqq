import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/models/project.dart';
import 'package:qfqq/common/providers/projects_provider.dart';

class ProjectSelectionDropdownWidget extends ConsumerWidget {
  final void Function(Project?) onSelected;

  const ProjectSelectionDropdownWidget({super.key, required this.onSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    TextEditingController controller = TextEditingController();

    final projects = ref.watch(projectsProvider);

    final List<DropdownMenuEntry<Project>> projectEntries =
        projects
            .map(
              (project) => DropdownMenuEntry<Project>(
                value: project,
                label: project.title,
              ),
            )
            .toList();

    return Center(
      child: DropdownMenu<Project>(
        controller: controller,
        enableFilter: true,
        requestFocusOnTap: true,
        leadingIcon: const Icon(Icons.search),
        label: const Text('Project'),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          contentPadding: EdgeInsets.symmetric(vertical: 5.0),
        ),
        onSelected: onSelected,
        dropdownMenuEntries: projectEntries,
      ),
    );
  }
}
