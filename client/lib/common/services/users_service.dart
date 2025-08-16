import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/models/user.dart';
import 'package:http/http.dart' as http;

class UsersService extends StateNotifier<List<User>> {
  final String _apiUrl;

  UsersService(String apiUrl) : _apiUrl = apiUrl, super([]) {
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final users = await getUsers();
    state = users;
  }

  Future<List<User>> getUsers() async {
    final response = await http.get(
      Uri.parse('$_apiUrl/users'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map(
            (item) => User(
              id: item['id'],
              username: item['username'],
              email: item['email'],
            ),
          )
          .toList();
    } else {
      throw Exception('Failed to fetch projects: ${response.statusCode}');
    }
  }
}
