import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:qfqq/common/models/errors/projects_error.dart';
import 'dart:convert';
import 'package:qfqq/common/models/project.dart';

class ProjectsService extends StateNotifier<List<Project>> {
  final String _apiUrl;

  ProjectsService(String apiUrl) : _apiUrl = apiUrl, super([]) {
    _loadProjects();
  }

  // TODO: Add feedback
  Future<ProjectErrors> createProject(Project project) async {
    final response = await http.post(
      Uri.parse('$_apiUrl/projects'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(project.toJson()),
    );

    dynamic data = jsonDecode(response.body);

    if (response.statusCode == 201) {
      data['number'] = _estimateProjectNumber();
      state = [...state, Project.fromJson(data)];
      return ProjectErrors();
    }
    return ProjectErrors.fromJson(data);
  }

  Future<ProjectErrors> updateProject(Project project) async {
    final response = await http.put(
      Uri.parse('$_apiUrl/projects'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(project.toJson()),
    );

    if (response.statusCode == 204) {
      final projects = state;
      state = projects.map((e) => e.id != project.id ? e : project).toList();
      return ProjectErrors();
    }

    dynamic data = jsonDecode(response.body);
    return ProjectErrors.fromJson(data);
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
      return data.map(Project.fromJson).toList();
    } else {
      throw Exception('Failed to fetch projects: ${response.statusCode}');
    }
  }
}
