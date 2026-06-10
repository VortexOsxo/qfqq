import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/models/invitation.dart';
import 'package:qfqq/common/services/auth_service.dart';
import 'package:qfqq/common/services/qfqq_http_client.dart';

class InvitationsService extends StateNotifier<List<Invitation>> {
  final QfqqHttpClient _http;

  InvitationsService(this._http, AuthService auth) : super([]) {
    auth.connectionNotifier.subscribe((_) => loadInvitations());
  }

  Future<void> addInvitations(List<String> emails, int roleId) async {
    final response = await _http.post(
      _http.getUri('organizations/invitations'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'emails': emails, 'roleId': roleId}),
    );

    if (response.statusCode != 201) {
      return;
    }

    final data = jsonDecode(response.body);
    final List<Invitation> addedInvitations = data.map<Invitation>(Invitation.fromJson).toList();

    if (addedInvitations.isEmpty) {
      return;
    }

    final merged = <String, Invitation>{};

    for (final invitation in state) {
      merged[_inviteKey(invitation)] = invitation;
    }

    for (final invitation in addedInvitations) {
      merged[_inviteKey(invitation)] = invitation;
    }

    state = merged.values.toList();
  }

  String _inviteKey(Invitation invitation) => '${invitation.orgId}:${invitation.email.toLowerCase()}';

  Future<void> loadInvitations() async {
    final response = await _http.get(
      _http.getUri('organizations/invitations'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      state = data.map(Invitation.fromJson).toList();
      print(state);
    }
  }
}
