import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/models/decision_event.dart';
import 'package:qfqq/common/services/qfqq_http_client.dart';

final decisionEventsProvider = FutureProvider.autoDispose
    .family<List<DecisionEvent>, int>((ref, decisionId) async {
      final http = ref.read(qfqqHttpClientProvider);
      final response = await http.get(
        http.getUri('decisions/$decisionId/events'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        return [];
      }

      final events = jsonDecode(response.body) as List<dynamic>;
      return events
          .map((event) => DecisionEvent.fromJson(event as Map<String, dynamic>))
          .toList();
    });
