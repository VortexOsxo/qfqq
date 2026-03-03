import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/models/project.dart';
import 'package:qfqq/common/providers/projects_provider.dart';
import 'package:qfqq/common/widgets/reusables/selection_text_fields/utils.dart';

class ProjectTextField extends ConsumerWidget {
  final String label;
  final int initialProjectId;
  final void Function(Project)? onSelected;
  final String? error;

  const ProjectTextField({
    super.key,
    required this.label,
    this.initialProjectId = 0,
    this.onSelected,
    this.error,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projects = ref.watch(projectsProvider);
    final currentProject = ref.read(projectProviderById(initialProjectId));

    List<Project> getOptions(TextEditingValue value) {
      var key = value.text.trim().toLowerCase();
      if (key.isEmpty) return projects;

      return projects
          .where((project) => project.title.toLowerCase().contains(key))
          .toList();
    }

    return Autocomplete<Project>(
      key: ValueKey('${currentProject?.id ?? 'no-id'}-${error ?? ''}'),
      optionsBuilder: getOptions,
      initialValue: TextEditingValue(
        text:
            currentProject != null
                ? _displayStringForOption(currentProject)
                : '',
      ),
      displayStringForOption: _displayStringForOption,
      onSelected: onSelected,
      fieldViewBuilder: defaultFieldViewBuilder(label, error, Icons.folder),
      optionsViewBuilder: defaultOptionsViewBuilder<Project>(
        (project, callback) => ListTile(title: Text(project.title), onTap: callback),
      ),
    );
  }

  static String _displayStringForOption(Project project) => project.title;
}
