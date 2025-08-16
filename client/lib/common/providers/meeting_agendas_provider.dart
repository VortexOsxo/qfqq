import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/models/meeting_agenda.dart';
import 'package:qfqq/common/services/meeting_agenda_service.dart';
import 'package:qfqq/common/providers/server_url.dart';

final meetingsAgendasProvider = StateNotifierProvider<MeetingAgendaService, List<MeetingAgenda>>(
  (ref) => MeetingAgendaService(ref.read(serverUrlProvider)),
);

final meetingAgendaByIdProvider = Provider.family<MeetingAgenda?, String>((ref, id) {
  final agendas = ref.watch(meetingsAgendasProvider);
  return agendas.firstWhere((agenda) => agenda.id == id);
});

final meetingAgendaServiceProvider = Provider<MeetingAgendaService>((ref) =>ref.read(meetingsAgendasProvider.notifier));