import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/services/qfqq_http_client.dart';

final reportsServiceProvider = Provider<ReportsService>(
  (ref) => ReportsService(ref.read(qfqqHttpClientProvider)),
);

class ReportsService {
  final QfqqHttpClient _client;

  ReportsService(this._client);

  Future<bool> sendReport(String reportUrl, List<String> emails) async {
    final response = await _client.post(
      _client.getUri('$reportUrl/send'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'emails': emails}),
    );
    return response.statusCode == 200;
  }
}
