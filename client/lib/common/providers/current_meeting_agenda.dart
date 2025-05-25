import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/models/meeting_agenda.dart';
  
final currentMeetingAgendaProvider = Provider<MeetingAgenda>((ref) {
  return MeetingAgenda(
    title: '',
    status: MeetingAgendaStatus.created,
    redactionDate: DateTime.now(),
  );
});

