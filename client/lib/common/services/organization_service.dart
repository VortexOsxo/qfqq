import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/services/qfqq_http_client.dart';

final organizationServiceProvider = Provider((ref) {
  final http = ref.watch(qfqqHttpClientProvider);
  return OrganizationService(http);
});

class OrganizationService {
  final QfqqHttpClient _http;

  OrganizationService(this._http);

  Future<String?> createOrganization(String name) async {
    final response = await _http.post(
      _http.getUri('organizations/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'organizationName': name}),
    );

    if (response.statusCode == 201) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return data['orgSlug'];
    }
    return null;
  }
}
