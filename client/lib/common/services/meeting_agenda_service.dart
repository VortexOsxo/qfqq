import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/models/meeting_agenda.dart';
import 'package:qfqq/common/models/meeting_review.dart';
import 'package:qfqq/common/providers/navigator_key.dart';
import 'package:qfqq/common/services/auth_service.dart';
import 'package:qfqq/common/services/decisions_service.dart';
import 'package:qfqq/common/services/qfqq_http_client.dart';
import 'package:qfqq/common/services/web_socket_service.dart';
import 'package:qfqq/common/widgets/modal/meeting_review_modal.dart';

class MeetingAgendaService extends StateNotifier<List<MeetingAgenda>> {
  final QfqqHttpClient _http;
  final DecisionsService decisionsService;

  int _currentMeeting = -1;

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

  Future<bool> startMeeting(int meetingId) async {
    final result = await updateMeetingAgendaStatus(
      meetingId,
      MeetingAgendaStatus.ongoing,
    );
    if (result) {
      WebSocketService.send("meeting", "start", {});
    }
    return result;
  }

  Future<bool> completeMeeting(int meetingId) async {
    final result = await updateMeetingAgendaStatus(
      meetingId,
      MeetingAgendaStatus.completed,
    );
    if (result) {
      WebSocketService.send("meeting", "end", {});
    }
    return result;
  }

  void onMeetingStatusUpdated(int meetingId, MeetingAgendaStatus status) {
    if (meetingId == -1) {
      return;
    }
    state = state
      .map((e) => (e.id != meetingId) ? e : e.copyWith(newStatus: status))
      .toList();
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

    onMeetingStatusUpdated(meetingId, status);
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

  Future<String> getMeetingCode(int meetingId) async {
    final response = await _http.get(
      _http.getUri('meeting-agendas/$meetingId/code'),
      headers: {'Content-Type': 'application/json'},
    );
    return response.body;
  }

  // TODO: Listen even if the meeting isn't started (we need to know when it starts)
  Future<void> joinMeeting(int meetingId) async {
    final code = await getMeetingCode(meetingId);
    _currentMeeting = meetingId;
    WebSocketService.registerHandler("meeting", _handler);
    WebSocketService.send("meeting", "join", {"code": code});
  }

  Future<void> leaveMeeting(int meetingId) async {
    WebSocketService.send("meeting", "leave", {});
    WebSocketService.unregisterHandler("meeting");
    _currentMeeting = -1;
  }

  Future<void> addReview(int meetingId, MeetingReview review) async {
    // TODO: Ajouter la gestion des erreurs
    final _ = await _http.post(
      _http.getUri('meeting-agendas/$meetingId/reviews'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(review.toJson()),
    );
  }

  Future<List<MeetingReview>> getReviews(int meetingId) async {
    final response = await _http.get(
      _http.getUri('meeting-agendas/$meetingId/reviews'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      return [];
    }

    final List<dynamic> body = jsonDecode(response.body);
    return body
        .map((item) => MeetingReview.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  void _handler(dynamic event) {
    if (event["type"] == "decision") {
      _reloadDecisions(_currentMeeting);
    } else if (event["type"] == "start") {
      onMeetingStatusUpdated(_currentMeeting, MeetingAgendaStatus.ongoing);
    } else if (event["type"] == "end") {
      onMeetingStatusUpdated(_currentMeeting, MeetingAgendaStatus.completed);
      _showEndMeetingReview();
    }
  }

  void _reloadDecisions(int meetingId) async {
    decisionsService.reload(); // TODO: Optimize, we don't want to reload all decisions, only the one we need to
  }

  void _showEndMeetingReview() {
    final context = navigatorKey.currentContext;
    if (context == null) {
      return;
    }

    assert(_currentMeeting != -1);

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => MeetingReviewModal(meetingId: _currentMeeting),
    );
  }
}
