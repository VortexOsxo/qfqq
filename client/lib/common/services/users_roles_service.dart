import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/models/user_role.dart';
import 'package:qfqq/common/services/qfqq_http_client.dart';

class UsersRolesService extends StateNotifier<List<UserRole>> {
  final QfqqHttpClient _http;

  UsersRolesService(this._http) : super([]) {
    _loadRoles();
  }

  Future<void> _loadRoles() async {
    final response = await _http.get(
      _http.getUri('users/roles'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) return;

    final List<dynamic> data = jsonDecode(response.body);
    state = data.map((item) => UserRole.fromJson(item)).toList();
  }

  Future<void> updateUserRole(int userId, int roleId) async {
    final response = await _http.patch(
      _http.getUri('users/$userId/role'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'roleId': roleId}),
    );

    if (response.statusCode != 204) return;

    UserRole update(UserRole userRole) {
      if (userRole.userId != userId) {
        return userRole.copyWith();
      }

      return userRole.copyWith(roleId: roleId);
    }

    state = state.map(update).toList();
  }
}
