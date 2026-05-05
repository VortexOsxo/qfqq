import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/models/meeting_agenda.dart';
import 'package:qfqq/common/services/auth_service.dart';
import 'package:qfqq/common/services/meeting_agenda_service.dart';
import 'package:qfqq/common/services/qfqq_http_client.dart';

final meetingsAgendasProvider = StateNotifierProvider<MeetingAgendaService, List<MeetingAgenda>>(
  (ref) => MeetingAgendaService(
    ref.read(qfqqHttpClientProvider),
    ref.read(authStateProvider.notifier),
  ),
);

final meetingAgendaByIdProvider = Provider.family<MeetingAgenda?, int>((ref, id) {
  final agendas = ref.watch(meetingsAgendasProvider);
  return agendas.firstWhereOrNull((agenda) => agenda.id == id);
});

final myMeetingsProvider = Provider<List<MeetingAgenda>>((ref) {
  final userId = ref.watch(authStateProvider.select((state) => state.user?.id));
  if (userId == null) return [];

  final agendas = ref.watch(meetingsAgendasProvider);
  return agendas
      .where(
        (a) =>
            (a.animatorId == userId || a.participantsIds.contains(userId)) &&
            (a.status == MeetingAgendaStatus.planned || a.status == MeetingAgendaStatus.ongoing) &&
            (a.meetingDate != null && a.meetingDate!.isAfter(DateTime.now().subtract(Duration(days: 1))))
      )
      .toList()
      ..sort((a, b) => a.meetingDate!.compareTo(b.meetingDate!));
});

final meetingAgendaServiceProvider = Provider<MeetingAgendaService>(
  (ref) => ref.read(meetingsAgendasProvider.notifier),
);