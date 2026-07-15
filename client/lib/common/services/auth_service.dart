import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:qfqq/common/models/errors/account_error.dart';
import 'package:qfqq/common/models/permissions.dart';
import 'package:qfqq/common/models/states/auth_state.dart';
import 'package:qfqq/common/models/user.dart';
import 'dart:convert';
import 'package:qfqq/common/utils/events/event_notifier.dart';
import 'package:qfqq/common/utils/storage.dart';
import 'package:qfqq/generated/l10n.dart';

final authStateProvider = StateNotifierProvider<AuthService, AuthState>(
  (_) => AuthService(),
);

const _version = String.fromEnvironment("VERSION");

class AuthService extends StateNotifier<AuthState> {
  static const String _apiUrl = String.fromEnvironment("API_URL");
  final EventNotifier<AuthState> connectionNotifier = EventNotifier();
  final EventNotifier<AuthState> disconnectionNotifier = EventNotifier();

  AuthService() : super(AuthState());

  String getSessionId() => state.sessionId;
  bool isAuthenticated() => state.isAuthenticated;

  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'QfqqVersion': _version,
  };

  static dynamic _safeJsonDecode(String body) {
    try {
      return jsonDecode(body);
    } catch (_) {
      return null;
    }
  }

  Future<AccountError> login(String email, String password, bool stay) async {
    final response = await http.post(
      Uri.parse('$_apiUrl/auth/login'),
      headers: _headers,
      body: jsonEncode({'email': email.toLowerCase().trim(), 'password': password}),
    );

    final data = _safeJsonDecode(response.body);
    if (data == null) return AccountError(authError: S.current.commonServerError);

    if (response.statusCode == 200) {
      _onSuccessfulAuth(data, stay: stay, clear: !stay);
      return AccountError();
    }
    return AccountError.fromJson(data);
  }

  Future<bool> refresh() async {
    final token = await storage.read(key: 'refresh_token');
    if (token == null) return false;

    final response = await http.post(
      Uri.parse('$_apiUrl/auth/refresh'),
      headers: {..._headers, 'Refresh': token},
    );
    if (response.statusCode == 200) {
      final data = _safeJsonDecode(response.body);
      if (data == null) return false;
      _onSuccessfulAuth(data);
      return true;
    }
    return false;
  }

  Future<AccountError> signup(User user, String password) async {
    final response = await http.post(
      Uri.parse('$_apiUrl/auth/signup'),
      headers: _headers,
      body: jsonEncode({
        'firstName': user.firstName,
        'lastName': user.lastName,
        'email': user.email.toLowerCase().trim(),
        'password': password,
      }),
    );

    final data = _safeJsonDecode(response.body);
    if (data == null) return AccountError(authError: S.current.commonServerError);

    if (response.statusCode == 201) {
      _onSuccessfulAuth(data);
      return AccountError();
    }
    // TODO: Improve error messages to be more descriptive
    return AccountError.fromJson(data);
  }

  void onOrgJoined(dynamic data) {
    _onSuccessfulAuth(data);
  }

  void logout() async {
    // TODO: Clear loaded data on disconnection
    await storage.delete(key: 'refresh_token');

    state = AuthState();
    disconnectionNotifier.notify(state);
  }

  _onSuccessfulAuth(dynamic data, {bool stay= false, bool clear = false}) {
    if (stay) {
      storage.write(key: 'refresh_token', value: data['refresh_token']);
    } else if (clear) {
      storage.delete(key: 'refresh_token');
    }

    state = AuthState(
      sessionId: data['session_token'],
      user: User.fromJson(data),
      hasOrg: data['hasOrg'],
      permissions: Permissions.fromJson(data),
    );
    connectionNotifier.notify(state);
  }
}
