import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/models/configs/saved_report_config.dart';
import 'package:qfqq/common/services/qfqq_http_client.dart';

final reportsServiceProvider = Provider<ReportsService>(
  (ref) => ReportsService(ref.read(qfqqHttpClientProvider)),
);

class ReportsService {
  final QfqqHttpClient _client;

  ReportsService(this._client);

  Future<List<SavedReportConfig>> getReportConfigs() async {
    final response = await _client.get(_client.getUri('reports/configs'));
    if (response.statusCode != 200) {
      throw StateError(
        'Failed to load report configurations (${response.statusCode})',
      );
    }

    final configs = jsonDecode(response.body) as List<dynamic>;
    return configs
        .map(
          (config) =>
              SavedReportConfig.fromJson(config as Map<String, dynamic>),
        )
        .toList();
  }

  Future<bool> saveReportConfig({
    required String name,
    required Map<String, String> parameters,
  }) async {
    final uri = _client
        .getUri('reports/configs')
        .replace(queryParameters: {'name': name, ...parameters});
    final response = await _client.post(uri);
    return response.statusCode == 201;
  }

  Future<bool> deleteReportConfig(int configId) async {
    final response = await _client.delete(
      _client.getUri('reports/configs/$configId'),
    );
    return response.statusCode == 204;
  }

  Future<bool> sendReport(String reportUrl, List<String> emails) async {
    final uri = Uri.parse(reportUrl);
    final sendUri = uri.replace(path: '${uri.path}/send');
    final response = await _client.post(
      _client.getUri(sendUri.toString()),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'emails': emails}),
    );
    return response.statusCode == 200;
  }
}
