import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import 'package:qfqq/common/models/meeting_agenda.dart';
import 'package:qfqq/common/services/qfqq_http_client.dart';

class MeetingAgendaService extends StateNotifier<List<MeetingAgenda>> {
  final QfqqHttpClient _http;

  MeetingAgendaService(this._http) : super([]) {
    _loadMeetingAgendas();
  }

  Future<bool> createMeetingAgenda(MeetingAgenda agenda) async {
    final response = await _http.post(
      _http.getUri('meeting-agendas'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(agenda),
    );

    if (response.statusCode != 201) return false;
    _loadMeetingAgendas();
    return true;
  }

  Future<List<MeetingAgenda>> getMeetingAgendas([String queryArgs = ""]) async {
    final response = await _http.get(
      _http.getUri('meeting-agendas/?$queryArgs'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) return [];

    final List<dynamic> data = jsonDecode(response.body);
    return data.map(MeetingAgenda.fromJson).toList();
  }

  Future<bool> updateMeetingAgenda(MeetingAgenda agenda) async {
    final response = await _http.put(
      _http.getUri('meeting-agendas'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(agenda),
    );
    if (response.statusCode != 200) return false;
    _loadMeetingAgendas();
    return true;
  }

  // TODO: Handle error
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
    _loadMeetingAgendas(); // TODO: don't load every meeting agenda
    return true;
  }

  MeetingAgenda? getMeetingAgendaById(int id) {
    return state.firstWhere((agenda) => agenda.id == id);
  }

  Future<void> _loadMeetingAgendas() async {
    final meetingAgendas = await getMeetingAgendas();
    state = meetingAgendas;
  }
}
