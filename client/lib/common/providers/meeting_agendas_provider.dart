import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/models/meeting_agenda.dart';
import 'package:qfqq/common/services/auth_service.dart';
import 'package:qfqq/common/services/meeting_agenda_service.dart';
import 'package:qfqq/common/providers/server_url.dart';

final meetingsAgendasProvider = StateNotifierProvider<MeetingAgendaService, List<MeetingAgenda>>(
  (ref) => MeetingAgendaService(ref.read(serverUrlProvider), ref.read(authStateProvider.notifier)),
);

final meetingAgendaByIdProvider = Provider.family<MeetingAgenda?, int>((ref, id) {
  final agendas = ref.watch(meetingsAgendasProvider);
  return agendas.firstWhere((agenda) => agenda.id == id);
});

final meetingAgendaServiceProvider = Provider<MeetingAgendaService>((ref) =>ref.read(meetingsAgendasProvider.notifier));