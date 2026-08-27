import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/services/auth_service.dart';
import 'package:qfqq/common/services/qfqq_http_client.dart';

final organizationServiceProvider = Provider((ref) {
  final http = ref.watch(qfqqHttpClientProvider);
  final auth = ref.read(authStateProvider.notifier);
  return OrganizationService(http, auth);
});

class OrganizationService {
  final QfqqHttpClient _http;
  final AuthService _authService;

  OrganizationService(this._http, this._authService);

  Future<void> createOrganization(String name) async {
    final response = await _http.post(
      _http.getUri('organizations/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'organizationName': name}),
    );

    if (response.statusCode != 200) {
      return;
    }
    final Map<String, dynamic> data = jsonDecode(response.body);
    if (!data.containsKey("session_token")) {
      return;
    }
    _authService.onOrgJoined(data);
  }
}
