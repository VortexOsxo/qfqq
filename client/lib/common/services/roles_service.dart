import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/models/errors/role_errors.dart';
import 'package:qfqq/common/models/role.dart';
import 'package:qfqq/common/services/qfqq_http_client.dart';

class RolesService extends StateNotifier<List<Role>> {
  final QfqqHttpClient _http;

  RolesService(this._http) : super([]) {
    _loadRoles();
  }

  Future<void> _loadRoles() async {
    final response = await _http.get(
      _http.getUri('roles'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) return;

    final List<dynamic> data = jsonDecode(response.body);
    state = data.map((item) => Role.fromJson(item)).toList();
  }

  Future<RoleErrors> createRole(Role role) async {
    final response = await _http.post(
      _http.getUri('roles'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(role),
    );

    dynamic data = jsonDecode(response.body);

    if (response.statusCode == 201) {
      state = [...state, Role.fromJson(data)];
      return RoleErrors();
    }
    return RoleErrors.fromJson(data);
  }

  Future<void> updateRole(int roleId, String permission, bool value) async {
    final response = await _http.patch(
      _http.getUri('roles/$roleId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "permission_name": permission,
        "permission_value": value,
      }),
    );

    Role update(Role role) {
      if (role.id != roleId) {
        return role;
      }

      if (permission == 'canWrite') {
        role.canWrite = value;
      } else if (permission == 'canDelete') {
        role.canDelete = value;
      } else if (permission == 'canUpdatePermissions') {
        role.canUpdatePermissions = value;
      }

      return role;
    }

    if (response.statusCode == 204) {
      state = state.map(update).toList();
    }
  }

  Future<bool> deleteRole(int roleId) async {
    final response = await _http.delete(
      _http.getUri('roles/$roleId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 204) {
      state = [...state].where((role) => role.id != roleId).toList();
      return true;
    }
    return false;
  }
}
