import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/services/auth_service.dart';
import 'package:qfqq/common/services/qfqq_http_client.dart';
import 'package:qfqq/generated/l10n.dart';

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

  Future<String?> joinOrganisation(int orgId) async {
    final response = await _http.post(
      _http.getUri('organizations/$orgId/join'),
      headers: {'Content-Type': 'application/json'},
    );
    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      _authService.onOrgJoined(data);
      return null;
    }

    final loc = S.current;
    if (data['userId'] == 1) {
      return loc.organizationJoinUserRequired;
    }

    if (data['orgId'] == 1) {
      return loc.errorRequiredField;
    }

    if (data['orgId'] == 15) {
      return loc.organizationJoinInvalidOrg;
    }

    return loc.errorUnknown;
  }

  Future<void> inviteMember(String email) async {
    final _ = await _http.post(
      _http.getUri('organizations/invite'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );
  }
}
