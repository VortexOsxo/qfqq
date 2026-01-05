import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:qfqq/common/models/meeting_agenda.dart';

class MeetingAgendaService extends StateNotifier<List<MeetingAgenda>> {
  final String _apiUrl;

  MeetingAgendaService(String apiUrl) : _apiUrl = apiUrl, super([]) {
    _loadMeetingAgendas();
  }

  Future<bool> createMeetingAgenda(MeetingAgenda agenda) async {
    final response = await http.post(
      Uri.parse('$_apiUrl/meeting-agendas'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(agenda),
    );

    return response.statusCode == 201;
  }

  Future<List<MeetingAgenda>> getMeetingAgendas() async {
    final response = await http.get(
      Uri.parse('$_apiUrl/meeting-agendas'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map(MeetingAgenda.fromJson).toList();
    } else {
      throw Exception(
        'Failed to fetch meeting agendas: ${response.statusCode}',
      );
    }
  }

  Future<bool> updateMeetingAgenda(MeetingAgenda agenda) async {
    final response = await http.put(
      Uri.parse('$_apiUrl/meeting-agendas'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(agenda),
    );
    return response.statusCode == 200;
  }

  MeetingAgenda? getMeetingAgendaById(String id) {
    return state.firstWhere((agenda) => agenda.id == id);
  }

  Future<void> _loadMeetingAgendas() async {
    final meetingAgendas = await getMeetingAgendas();
    state = meetingAgendas;
  }
}
