import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/models/meeting_agenda.dart';
import 'package:qfqq/common/services/auth_service.dart';
import 'package:qfqq/common/services/decisions_service.dart';
import 'package:qfqq/common/services/qfqq_http_client.dart';

class MeetingAgendaService extends StateNotifier<List<MeetingAgenda>> {
  final QfqqHttpClient _http;
  final DecisionsService decisionsService;

  MeetingAgendaService(this._http, AuthService auth, this.decisionsService) : super([]) {
    auth.connectionNotifier.subscribe((_) => _loadMeetingAgendas());
  }

  Future<bool> createMeetingAgenda(MeetingAgenda agenda, {int? previousMeetingId}) async {
    var body =
        previousMeetingId != null
            ? jsonEncode({
              ...agenda.toJson(),
              'previousMeetingId': previousMeetingId,
            })
            : jsonEncode(agenda);

    final response = await _http.post(
      _http.getUri('meeting-agendas'),
      headers: {'Content-Type': 'application/json'},
      body: body
    );

    dynamic data = jsonDecode(response.body);

    if (response.statusCode == 201) {
      state = [...state, MeetingAgenda.fromJson(data)];
      return true;
    }
    return false;
  }

  Future<bool> updateMeetingAgenda(MeetingAgenda agenda) async {
    final response = await _http.put(
      _http.getUri('meeting-agendas'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(agenda),
    );
    if (response.statusCode != 204) return false;

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

    state = state.map(
      (e) => (e.id != meetingId) ? e : e.copyWith(newStatus: status)
    ).toList();
    return true;
  }

  Future<bool> deleteMeetingAgenda(int meetingId) async {
    final response = await _http.delete(
      _http.getUri('meeting-agendas/$meetingId'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode != 204) return false;

    state = state.where((e) => e.id != meetingId).toList();
    decisionsService.meetingRemoved(meetingId);
    return true;
  }

  void projectRemoved(int projectId) {
    final meetingsToRemove = state.where((m) => m.projectId == projectId).toList();
    if (meetingsToRemove.isEmpty) return;
    
    state = state.where((m) => m.projectId != projectId).toList();
    for (var meeting in meetingsToRemove) {
      decisionsService.meetingRemoved(meeting.id);
    }
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
