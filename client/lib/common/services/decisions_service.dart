import 'package:qfqq/common/models/decision.dart';
import 'dart:convert';
import 'package:qfqq/common/services/qfqq_http_client.dart';

class DecisionsService {
  final QfqqHttpClient _http;

  DecisionsService(this._http);

  Future<bool> createDecision(Decision decision) async {
    final response = await _http.post(
      _http.getUri('decisions'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(decision),
    );

    return response.statusCode == 201;
  }

  Future<List<Decision>> getDecisions([String queryArgs = ""]) async {
    final response = await _http.get(
      _http.getUri('decisions/?$queryArgs'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) return [];

    final List<dynamic> data = jsonDecode(response.body);
    return data.map((item) => Decision.fromJson(item)).toList();
  }
}
