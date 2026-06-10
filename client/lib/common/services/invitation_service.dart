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

  Future<void> addInvitation(String email, int roleId) async {
    final response = await _http.post(
      _http.getUri('organizations/invitations'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'roleId': roleId}),
    );

    if (response.statusCode != 201) {
      return;
    }

    final data = jsonDecode(response.body);
    Invitation invitation;
    try {
      invitation = Invitation.fromJson(data);
    } catch (e) {
      return;
    }

    final updatedState = [...state];
    final index = updatedState.indexWhere((existing) {
      return existing.orgId == invitation.orgId &&
          existing.email.toLowerCase() == invitation.email.toLowerCase();
    });

    if (index >= 0) {
      updatedState[index] = invitation;
    } else {
      updatedState.add(invitation);
    }

    state = updatedState;
  }

  Future<void> revokeInvitation(String email) async {
    final response = await _http.delete(
      _http.getUri('organizations/invitations/$email'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      return;
    }

    state = state.where((e) => e.email != email).toList();
  }


  Future<void> loadInvitations() async {
    final response = await _http.get(
      _http.getUri('organizations/invitations'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      state = data.map(Invitation.fromJson).toList();
    }
  }
}
