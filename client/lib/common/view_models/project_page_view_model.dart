import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qfqq/common/models/enums/id_selection_enum.dart';
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
  bool isRefreshing = false;
  int? userIdQuery;

  List<Project> get filteredProjects {
    var projects = ref.watch(projectsProvider);

    if (searchQuery.isNotEmpty) {
      projects = projects
          .where(
            (project) =>
                project.title.toLowerCase().contains(
                  searchQuery.toLowerCase(),
                ) ||
                project.number.toString().contains(searchQuery.toLowerCase()),
          )
          .toList();
    }

    if (userIdQuery == IdSelection.noId.value) {
      projects = projects
          .where((project) => !isIdValid(project.supervisorId))
          .toList();
    } else if (isIdValid(userIdQuery)) {
      projects = projects
          .where((project) => project.supervisorId == userIdQuery)
          .toList();
    }
    return projects;
  }

  String supervisorName(int supervisorId, String fallback) {
    if (!isIdValid(supervisorId)) return fallback;
    return ref.watch(userByIdProvider(supervisorId))?.displayName ?? fallback;
  }

  void onSearchQueryChanged(String value) => setState(() => searchQuery = value);
  void onUserQueryChanged(int? value) => setState(() => userIdQuery = value);

  Future<void> refreshProjects() async {
    if (isRefreshing) return;

    setState(() => isRefreshing = true);
    try {
      await ref.read(projectsServiceProvider).refreshProjects();
    } finally {
      if (mounted) setState(() => isRefreshing = false);
    }
  }

  void goToProjectCreation() => context.go('/projects/creation');

  void goToProject(int projectId) => context.go('/projects/$projectId');

  @override
  Widget build(BuildContext context) => widget.builder(this);
}
