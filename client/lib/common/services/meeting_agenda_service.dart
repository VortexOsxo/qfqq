import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/models/meeting_agenda.dart';
import 'package:qfqq/common/services/auth_service.dart';
import 'package:qfqq/common/services/qfqq_http_client.dart';

class MeetingAgendaService extends StateNotifier<List<MeetingAgenda>> {
  final QfqqHttpClient _http;

  MeetingAgendaService(this._http, AuthService auth) : super([]) {
    auth.connectionNotifier.subscribe((_) => _loadMeetingAgendas());
  }

  Future<bool> createMeetingAgenda(MeetingAgenda agenda) async {
    final response = await _http.post(
      _http.getUri('meeting-agendas'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(agenda),
    );

    if (response.statusCode != 201) return false;

    await _loadMeetingAgendas();
    return true;
  }

  Future<bool> updateMeetingAgenda(MeetingAgenda agenda) async {
    final response = await _http.put(
      _http.getUri('meeting-agendas'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(agenda),
    );
    if (response.statusCode != 200) return false;

    state = state.map((e) => e.id != agenda.id ? e : agenda).toList();
    return true;
  }

  Future<bool> updateMeetingAgendaStatus(
    int meetingId,
    MeetingAgendaStatus status,
  ) async {
    final response = await _http.patch(
      _http.getUri('meeting-agendas/$meetingId/status'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'status': status.name}),
    );
    if (response.statusCode != 204) return false;

    state = state.map((e) {
      if (e.id != meetingId) return e;
      e.status = status;
      return e;
    }).toList();
    return true;
  }

  Future<void> _loadMeetingAgendas() async {
    final response = await _http.get(
      _http.getUri('meeting-agendas/'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) return;

    final List<dynamic> data = jsonDecode(response.body);
    state = data.map(MeetingAgenda.fromJson).toList();
  }
}
