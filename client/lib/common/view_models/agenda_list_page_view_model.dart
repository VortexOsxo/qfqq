import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qfqq/common/models/enums/id_selection_enum.dart';
import 'package:qfqq/common/models/meeting_agenda.dart';
import 'package:qfqq/common/models/project.dart';
import 'package:qfqq/common/providers/meeting_agendas_provider.dart';
import 'package:qfqq/common/providers/projects_provider.dart';
import 'package:qfqq/common/providers/users_provider.dart';
import 'package:qfqq/common/utils/is_id_valid.dart';

class AgendaListPageViewModel extends ConsumerStatefulWidget {
  final Widget Function(AgendaListPageViewModelState vm) builder;

  const AgendaListPageViewModel({super.key, required this.builder});

  @override
  ConsumerState<AgendaListPageViewModel> createState() => AgendaListPageViewModelState();
}

class AgendaListPageViewModelState extends ConsumerState<AgendaListPageViewModel> {
  String searchQuery = '';
  MeetingAgendaStatus? statusQuery;
  int? projectIdQuery;
  int? animatorIdQuery;
  bool isRefreshing = false;

  List<MeetingAgenda> get filteredAgendas {
    var agendas = ref.watch(meetingsAgendasProvider);

    if (searchQuery.isNotEmpty) {
      agendas =
          agendas
              .where(
                (agenda) =>
                    agenda.title.toLowerCase().contains(
                      searchQuery.toLowerCase(),
                    ) ||
                    agenda.number.toString().contains(searchQuery),
              )
              .toList();
    }

    if (statusQuery != null) {
      agendas =
          agendas
              .where((MeetingAgenda agenda) => agenda.status == statusQuery)
              .toList();
    }

    if (projectIdQuery == IdSelection.noId.value) {
      agendas =
          agendas.where((agenda) => !isIdValid(agenda.projectId)).toList();
    } else if (isIdValid(projectIdQuery)) {
      agendas =
          agendas
              .where((agenda) => agenda.projectId == projectIdQuery)
              .toList();
    }

    if (animatorIdQuery == IdSelection.noId.value) {
      agendas =
          agendas.where((agenda) => !isIdValid(agenda.animatorId)).toList();
    } else if (isIdValid(animatorIdQuery)) {
      agendas =
          agendas
              .where((agenda) => agenda.animatorId == animatorIdQuery)
              .toList();
    }

    return agendas;
  }

  List<Project> get projects => ref.watch(projectsProvider);

  String animatorName(int? animatorId, String fallback) {
    if (!isIdValid(animatorId)) return fallback;
    return ref.watch(userByIdProvider(animatorId!))?.displayName ?? fallback;
  }

  void onSearchQueryChanged(String value) => setState(() => searchQuery = value);
  void onStatusQueryChanged(MeetingAgendaStatus? value) => setState(() => statusQuery = value);
  void onProjectQueryChanged(int? value) => setState(() => projectIdQuery = value);
  void onAnimatorQueryChanged(int? value) => setState(() => animatorIdQuery = value);

  Future<void> refreshAgendas() async {
    if (isRefreshing) return;

    setState(() => isRefreshing = true);
    try {
      await ref.read(meetingAgendaServiceProvider).refreshMeetingAgendas();
    } finally {
      if (mounted) setState(() => isRefreshing = false);
    }
  }

  void goToAgendaCreation() => context.push('/agendas/creation');
  void goToAgenda(int agendaId) => context.push('/agendas/$agendaId');

  @override
  Widget build(BuildContext context) => widget.builder(this);
}
