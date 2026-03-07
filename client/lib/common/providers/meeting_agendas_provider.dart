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
  final agendas = ref.watch(meetingsAgendasProvider);
  final userId = ref.watch(authStateProvider.select((state) => state.userId));
  if (userId == null) return [];

  return agendas.where((a) => a.participantsIds.contains(userId)).toList();
});

final meetingAgendaServiceProvider = Provider<MeetingAgendaService>(
  (ref) => ref.read(meetingsAgendasProvider.notifier),
);