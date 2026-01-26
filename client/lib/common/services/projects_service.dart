import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:qfqq/common/models/project.dart';

class ProjectsService extends StateNotifier<List<Project>> {
  final String _apiUrl;

  ProjectsService(String apiUrl) : _apiUrl = apiUrl, super([]) {
    _loadProjects();
  }

  // TODO: Add feedback
  Future<bool> createProject(Project project) async {
    final response = await http.post(
      Uri.parse('$_apiUrl/projects'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(project.toJson()),
    );

    if (response.statusCode == 201) {
      dynamic data = jsonDecode(response.body);
      data['number'] = _estimateProjectNumber();
      state = [...state, Project.fromJson(data)];
      return true;
    }
    return false;
  }

  Future<void> updateProject(Project project) async {
    await http.put(
      Uri.parse('$_apiUrl/projects'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(project.toJson()),
    );

    final projects = state;
    state = projects.map((e) => e.id != project.id ? e : project).toList();
  }

  Future<void> _loadProjects() async {
    final projects = await getProjects();
    state = projects;
  }

  int _estimateProjectNumber() {
    if (state.isEmpty) return 1;
    
    final numbers = state.map((project) => project.number).toList();
    return (numbers.reduce((a, b) => a > b ? a : b)) + 1;
  }

  Future<List<Project>> getProjects() async {
    final response = await http.get(
      Uri.parse('$_apiUrl/projects'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map(Project.fromJson)
        .toList();
    } else {
      throw Exception('Failed to fetch projects: ${response.statusCode}');
    }
  }
}
