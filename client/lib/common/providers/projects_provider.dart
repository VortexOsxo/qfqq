import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/models/project.dart';
import 'package:qfqq/common/providers/server_url.dart';
import 'package:qfqq/common/services/projects_service.dart';
import 'package:collection/collection.dart';

final projectsProvider = StateNotifierProvider<ProjectsService, List<Project>>(
  (ref) => ProjectsService(ref.read(serverUrlProvider)),
);

final projectProviderById = Provider.family<Project?, String>((ref, id) {
  final projects = ref.watch(projectsProvider);
  return projects.firstWhereOrNull((project) => project.id == id);
});

final projectsServiceProvider = Provider<ProjectsService>((ref) =>ref.read(projectsProvider.notifier));