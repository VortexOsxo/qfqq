import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/models/decision.dart';
import 'package:qfqq/common/services/auth_service.dart';
import 'package:qfqq/common/services/qfqq_http_client.dart';

class DecisionsService extends StateNotifier<List<Decision>> {
  final QfqqHttpClient _http;

  DecisionsService(this._http, AuthService auth) : super([]) {
    auth.connectionNotifier.subscribe((_) => loadData());
  }

  Future<void> loadData() async {
    final response = await _http.get(
      _http.getUri('decisions/'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) return;

    final List<dynamic> data = jsonDecode(response.body);
    state = data.map((item) => Decision.fromJson(item)).toList();
  }

  Future<bool> createDecision(Decision decision) async {
    final response = await _http.post(
      _http.getUri('decisions'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(decision),
    );

    if (response.statusCode != 201) return false;

    // Reload to get server-assigned id/number
    await loadData();
    return true;
  }
}
