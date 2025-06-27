import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:qfqq/common/models/project.dart';
import 'package:qfqq/common/providers/serverl_url.dart';

final projectServiceProvider = Provider<ProjectService>(
  (ref) => ProjectService(ref.read(serverUrlProvider)),
);

class ProjectService {
  final String _apiUrl;

  ProjectService(String apiUrl) : _apiUrl = apiUrl;

  // TODO: Add feedback
  Future<bool> createProject({
    required String title,
    required String description,
  }) async {
    final response = await http.post(
      Uri.parse('$_apiUrl/projects'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'title': title, 'description': description}),
    );

    return response.statusCode == 201;
  }

  Future<List<Project>> getProjects() async {
    final response = await http.get(
      Uri.parse('$_apiUrl/projects'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map(
            (item) => Project(
              id: item['id'] ?? '',
              title: item['title'] ?? '',
              description: item['description'] ?? '',
            ),
          )
          .toList();
    } else {
      throw Exception(
        'Failed to fetch projects: ${response.statusCode}',
      );
    }
  }
}
