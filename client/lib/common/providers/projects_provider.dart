import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/models/project.dart';
import 'package:qfqq/common/services/auth_service.dart';
import 'package:qfqq/common/services/projects_service.dart';
import 'package:qfqq/common/services/qfqq_http_client.dart';
import 'package:qfqq/common/providers/meeting_agendas_provider.dart';

final projectsProvider = StateNotifierProvider<ProjectsService, List<Project>>(
  (ref) => ProjectsService(
    ref.read(qfqqHttpClientProvider),
    ref.read(authStateProvider.notifier),
    ref.read(meetingAgendaServiceProvider),
  ),
);

final projectProviderById = Provider.family<Project?, int>((ref, id) {
  final projects = ref.watch(projectsProvider);
  return projects.firstWhereOrNull((project) => project.id == id);
});

final projectsServiceProvider = Provider<ProjectsService>(
  (ref) => ref.read(projectsProvider.notifier),
);