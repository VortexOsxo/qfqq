import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/models/user.dart';
import 'package:qfqq/common/services/auth_service.dart';
import 'package:qfqq/common/services/qfqq_http_client.dart';

class UsersService extends StateNotifier<List<User>> {
  final QfqqHttpClient _http;

  UsersService(this._http, AuthService auth) : super([]) {
    auth.connectionNotifier.subscribe((_) => _loadUsers());
  }

  Future<void> _loadUsers() async {
    final response = await _http.get(
      _http.getUri("/users"),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      state = data
          .map(
            (item) => User(
              id: item['id'],
              username: item['username'],
              email: item['email'],
            ),
          )
          .toList();
    }
  }
}
