import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/models/decision.dart';
import 'package:qfqq/common/services/auth_service.dart';
import 'package:qfqq/common/services/qfqq_http_client.dart';

class DecisionsService extends StateNotifier<List<Decision>> {
  final QfqqHttpClient _http;

  DecisionsService(this._http, AuthService auth) : super([]) {
    auth.connectionNotifier.subscribe((_) => _loadDecisions());
  }

  Future<void> _loadDecisions() async {
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

    if (response.statusCode == 201) {
      dynamic data = jsonDecode(response.body);
      state = [...state, Decision.fromJson(data)];
      return true;
    }
    return false;
  }

  Future<bool> updateDecisionStatus(
    int decisionId,
    DecisionStatus status,
  ) async {
    final response = await _http.patch(
      _http.getUri('decisions/$decisionId/status'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'status': status.name}),
    );
    if (response.statusCode != 204) return false;

    Decision update(Decision decision) {
      if (decision.id != decisionId) {
        return decision;
      }

      decision = decision.copyWith(newStatus: status);
      if (status == DecisionStatus.completed) {
        decision.completedDate = DateTime.now().copyWith(
          hour: 0,
          minute: 0,
          second: 0,
          millisecond: 0,
          microsecond: 0,
        );
      }
      return decision;
    }

    state = state.map(update).toList();
    return true;
  }
}
