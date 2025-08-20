import 'package:http/http.dart' as http;
import 'package:qfqq/common/models/decision.dart';
import 'dart:convert';
import 'package:qfqq/common/services/auth_service.dart';

class DecisionsService {
  final String _apiUrl;
  final AuthService _authService;

  DecisionsService(String apiUrl, AuthService authService)
    : _apiUrl = apiUrl,
      _authService = authService;

  Future<bool> createDecision({
    required String description,
    String? projectId,
    String? responsibleId,
    List<String>? assistantsId,
  }) async {
    final headers = _authService.addAuthHeader({
      'Content-Type': 'application/json',
    });

    final response = await http.post(
      Uri.parse('$_apiUrl/decisions'),
      headers: headers,
      body: jsonEncode({
        'description': description,
        if (projectId != null) 'projectId': projectId,
        if (responsibleId != null) 'responsibleId': responsibleId,
        if (assistantsId != null) 'assistantsId': assistantsId,
      }),
    );

    return response.statusCode == 201;
  }

  Future<List<Decision>> loadDecisions([String queryArgs = ""]) async {
    final response = await http.get(
      Uri.parse('$_apiUrl/decisions?$queryArgs'),
      headers: _authService.addAuthHeader({'Content-Type': 'application/json'}),
    );

    if (response.statusCode != 200) return [];

    final List<dynamic> data = jsonDecode(response.body);
    return data
        .map(
          (item) => Decision(
            id: item['id'],
            description: item['description'],
            status: DecisionStatus.values[item['status']],
            initialDate: DateTime.parse(item['initialDate']),
            dueDate:
                item['dueDate'] != null
                    ? DateTime.parse(item['dueDate'])
                    : null,
            responsibleId: item['responsibleId'],
            assistantsId:
                item['assistantsId'] != null
                    ? List<String>.from(item['assistantsId'])
                    : [],
            projectId: item['projectId'],
          ),
        )
        .toList();
  }
}
