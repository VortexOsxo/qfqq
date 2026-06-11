import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qfqq/common/models/project.dart';
import 'package:qfqq/common/providers/projects_provider.dart';
import 'package:qfqq/common/providers/users_provider.dart';
import 'package:qfqq/common/utils/is_id_valid.dart';

class ProjectPageViewModel extends ConsumerStatefulWidget {
  final Widget Function(ProjectPageViewModelState vm) builder;

  const ProjectPageViewModel({super.key, required this.builder});

  @override
  ConsumerState<ProjectPageViewModel> createState() =>
      ProjectPageViewModelState();
}

class ProjectPageViewModelState extends ConsumerState<ProjectPageViewModel> {
  String searchQuery = '';

  List<Project> get filteredProjects {
    final projects = ref.watch(projectsProvider);

    if (searchQuery.isEmpty) return projects;

    return projects
        .where(
          (project) =>
              project.title
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase()) ||
              project.number.toString().contains(searchQuery.toLowerCase()),
        )
        .toList();
  }

  String supervisorName(int supervisorId, String fallback) {
    if (!isIdValid(supervisorId)) return fallback;
    return ref.watch(userByIdProvider(supervisorId))?.displayName ?? fallback;
  }

  void onSearchQueryChanged(String value) => setState(() => searchQuery = value);

  void goToProjectCreation() => context.go('/projects/creation');

  void goToProject(int projectId) => context.go('/projects/$projectId');

  @override
  Widget build(BuildContext context) => widget.builder(this);
}
