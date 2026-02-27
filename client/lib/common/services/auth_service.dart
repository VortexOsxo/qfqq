import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:qfqq/common/models/errors/account_error.dart';
import 'dart:convert';
import 'package:qfqq/common/utils/events/event_notifier.dart';

final authStateProvider = StateNotifierProvider<AuthService, AuthState>(
  (ref) => AuthService(ref),
);

class AuthState {
  final String sessionId;
  final String? email;
  final String? username;

  bool get isAuthenticated => sessionId.isNotEmpty;
  AuthState({String? sessionId, this.email, this.username})
    : sessionId = sessionId ?? "";

  AuthState copyWith({String? sessionId, String? email, String? username}) {
    return AuthState(
      sessionId: sessionId ?? this.sessionId,
      email: email ?? this.email,
      username: username ?? this.username,
    );
  }
}

const _version = String.fromEnvironment("VERSION");

class AuthService extends StateNotifier<AuthState> {
  static const String _apiUrl = String.fromEnvironment("API_URL");
  final EventNotifier<String> connectionNotifier = EventNotifier<String>();
  final EventNotifier<String> disconnectionNotifier = EventNotifier<String>();

  AuthService(Ref ref) : super(AuthState());

  String getSessionId() {
    return state.sessionId;
  }

  Future<AccountError> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$_apiUrl/auth/login'),
      headers: {'Content-Type': 'application/json', 'QfqqVersion': _version},
      body: jsonEncode({'email': email, 'password': password}),
    );
    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      _onSuccessfulAuth(data['session_token'], data['email'], data['username']);
      return AccountError();
    }
    return AccountError.fromJson(data);
  }

  Future<AccountError> signup(
    String username,
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$_apiUrl/auth/signup'),
      headers: {'Content-Type': 'application/json', 'QfqqVersion': _version},
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
      }),
    );
    final data = jsonDecode(response.body);

    if (response.statusCode == 201) {
      _onSuccessfulAuth(data['session_token'], data['email'], data['username']);
      return AccountError();
    }
    // TODO: Improve error messages to be more descriptive
    return AccountError.fromJson(data);
  }

  void logout() {
    // TODO: Clear loaded data on disconnection
    state = AuthState();
    disconnectionNotifier.notify("");
  }

  // TODO: Handle successful auth
  _onSuccessfulAuth(String sessionId, String email, String username) {
    state = AuthState(sessionId: sessionId, email: email, username: username);
    connectionNotifier.notify(email);
  }
}
