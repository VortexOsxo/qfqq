import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/models/project.dart';
import 'package:qfqq/common/providers/projects_provider.dart';

class ProjectTextField extends ConsumerWidget {
  final String label;
  final String initialProjectId;
  final void Function(Project)? onSelected;
  final String? error;

  const ProjectTextField({
    super.key,
    required this.label,
    this.initialProjectId = '',
    this.onSelected,
    this.error,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projects = ref.watch(projectsProvider);
    final currentProject = projects.cast<Project?>().firstWhere((project) => project?.id == initialProjectId, orElse: () => null);
    
    List<Project> getOptions(TextEditingValue value) {
      var key = value.text.trim().toLowerCase();
      if (key.isEmpty) return const [];

      // TODO: Utilize Levenshtein distance to allow for some mistake ?
      return projects.where(
        (project) => project.title.toLowerCase().contains(key)
      ).toList();
    }

    Widget fieldViewBuilder(
      BuildContext context,
      TextEditingController textController,
      FocusNode focusNode,
      VoidCallback onFieldSubmitted,
    ) {
      return TextField(
        controller: textController,
        focusNode: focusNode,
        decoration: InputDecoration(
          labelText: label,
          errorText: error,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          prefixIcon: const Icon(Icons.person),
        ),
      );
    }

    return Autocomplete<Project>(
      key: ValueKey('${currentProject?.id ?? 'no-id'}-${error ?? ''}'),
      optionsBuilder: getOptions,
      initialValue: TextEditingValue(
        text: currentProject != null ? _displayStringForOption(currentProject) : '',
      ),
      displayStringForOption: _displayStringForOption,
      onSelected: onSelected,
      fieldViewBuilder: fieldViewBuilder,
    );
  }

  static String _displayStringForOption(Project project) => project.title;
}
