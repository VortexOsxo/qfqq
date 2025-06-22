import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:qfqq/common/models/meeting_agenda.dart';
import 'package:qfqq/common/providers/serverl_url.dart';

final meetingAgendaServiceProvider = Provider<MeetingAgendaService>((ref) => MeetingAgendaService(ref.read(serverUrlProvider)));

class MeetingAgendaService {
  final String _apiUrl;

  MeetingAgendaService(String apiUrl) : _apiUrl = apiUrl;

  Future<bool> createMeetingAgenda({
    required String title,
    required DateTime redactionDate,
    MeetingAgendaStatus status = MeetingAgendaStatus.created,
    required String reunionGoals,
    DateTime? reunionDate,
    String? reunionLocation,
    String? animator,
    List<String>? participants,
    List<String>? themes,
    String? project,
  }) async {
    final response = await http.post(
      Uri.parse('$_apiUrl/meeting-agendas'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'title': title,
        'redactionDate': redactionDate.toIso8601String(),
        'status': status.toString().split('.').last,
        'reunionGoals': reunionGoals,
        if (reunionDate != null) 'reunionDate': reunionDate.toIso8601String(),
        if (reunionLocation != null) 'reunionLocation': reunionLocation,
        if (animator != null) 'animator': animator,
        if (participants != null) 'participants': participants,
        if (themes != null) 'themes': themes,
        if (project != null) 'project': project,
      }),
    );

    return response.statusCode == 201;
  }

  Future<List<MeetingAgenda>> getMeetingAgendas() async {
    final response = await http.get(
      Uri.parse('$_apiUrl/meeting-agendas'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => MeetingAgenda(
        id: item['id'],
        title: item['title'],
        redactionDate: DateTime.parse(item['redactionDate']),
        status: MeetingAgendaStatus.values.firstWhere(
          (e) => e.toString().split('.').last == item['status'],
        ),
      )..reunionGoals = item['reunionGoals']
        ..reunionDate = item['reunionDate'] != null ? DateTime.parse(item['reunionDate']) : null
        ..reunionLocation = item['reunionLocation']
        ..animator = item['animator']
        ..participants = List<String>.from(item['participants'] ?? [])
        ..themes = List<String>.from(item['themes'] ?? [])
        ..project = item['project'] ?? ''
      ).toList();
    } else {
      throw Exception('Failed to fetch meeting agendas: ${response.statusCode}');
    }
  }

  Future<bool> updateMeetingAgenda({
    required String id,
    required String title,
    required DateTime redactionDate,
    MeetingAgendaStatus status = MeetingAgendaStatus.created,
    required String reunionGoals,
    DateTime? reunionDate,
    String? reunionLocation,
    String? animator,
    List<String>? participants,
    List<String>? themes,
    String? project,
  }) async {
    final response = await http.put(
      Uri.parse('$_apiUrl/meeting-agendas/$id'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'title': title,
        'redactionDate': redactionDate.toIso8601String(),
        'status': status.toString().split('.').last,
        'reunionGoals': reunionGoals,
        if (reunionDate != null) 'reunionDate': reunionDate.toIso8601String(),
        if (reunionLocation != null) 'reunionLocation': reunionLocation,
        if (animator != null) 'animator': animator,
        if (participants != null) 'participants': participants,
        if (themes != null) 'themes': themes,
        if (project != null) 'project': project,
      }),
    );
    return response.statusCode == 200;
  }
} 