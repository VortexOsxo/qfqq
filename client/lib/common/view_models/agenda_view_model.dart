import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/models/meeting_agenda.dart';
import 'package:qfqq/common/providers/meeting_agendas_provider.dart';
import 'package:qfqq/common/providers/users_provider.dart';
import 'package:qfqq/common/utils/is_id_valid.dart';

class AgendaViewModel extends ConsumerStatefulWidget {
  final int agendaId;
  final Widget Function(AgendaViewPageViewModelState vm) builder;

  const AgendaViewModel({
    super.key,
    required this.agendaId,
    required this.builder,
  });

  @override
  ConsumerState<AgendaViewModel> createState() => AgendaViewPageViewModelState();
}

class AgendaViewPageViewModelState extends ConsumerState<AgendaViewModel> {
  MeetingAgenda? get agenda => ref.watch(meetingAgendaByIdProvider(widget.agendaId));

  bool get hasProject => isIdValid(agenda?.projectId);

  int get projectId => agenda?.projectId ?? 0;

  String get animatorName {
    final animatorId = agenda?.animatorId;
    if (!isIdValid(animatorId)) return '';
    return ref.watch(userByIdProvider(animatorId!))?.displayName ?? '';
  }

  List<String> get participantNames {
    final participants = agenda?.participantsIds ?? [];
    return participants
        .map((participantId) => ref.watch(userByIdProvider(participantId))?.displayName ?? '')
        .toList();
  }

  @override
  Widget build(BuildContext context) => widget.builder(this);
}
