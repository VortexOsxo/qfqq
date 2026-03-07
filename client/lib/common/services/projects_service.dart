import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/models/project.dart';
import 'package:qfqq/common/models/errors/project_errors.dart';
import 'package:qfqq/common/services/auth_service.dart';
import 'package:qfqq/common/services/qfqq_http_client.dart';

class ProjectsService extends StateNotifier<List<Project>> {
  final QfqqHttpClient _http;

  ProjectsService(this._http, AuthService auth) : super([]) {
    auth.connectionNotifier.subscribe((_) => _loadProjects());
  }

  Future<ProjectErrors> createProject(Project project) async {
    final response = await _http.post(
      _http.getUri('projects'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(project.toJson()),
    );

    dynamic data = jsonDecode(response.body);

    if (response.statusCode == 201) {
      state = [...state, Project.fromJson(data)];
      return ProjectErrors();
    }
    return ProjectErrors.fromJson(data);
  }

  Future<ProjectErrors> updateProject(Project project) async {
    final response = await _http.put(
      _http.getUri('projects'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(project.toJson()),
    );

    if (response.statusCode == 204) {
      state = state.map((e) => e.id != project.id ? e : project).toList();
      return ProjectErrors();
    }

    dynamic data = jsonDecode(response.body);
    return ProjectErrors.fromJson(data);
  }

  Future<void> _loadProjects() async {
    final response = await _http.get(
      _http.getUri('projects'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      state = data.map(Project.fromJson).toList();
    }
  }
}
