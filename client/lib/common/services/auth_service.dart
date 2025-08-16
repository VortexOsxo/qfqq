import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:qfqq/common/models/account_error.dart';
import 'dart:convert';
import 'package:qfqq/common/providers/server_url.dart';
import 'package:qfqq/common/utils/events/event_notifier.dart';
import 'package:qfqq/generated/l10n.dart';

final authStateProvider = StateNotifierProvider<AuthService, AuthState>(
  (ref) => AuthService(ref),
);

class AuthState {
  final String sessionId;
  bool get isAuthenticated => sessionId.isNotEmpty;
  AuthState({String? sessionId, String? username})
    : sessionId = sessionId ?? "";

  AuthState copyWith({String? sessionId, String? username}) {
    return AuthState(sessionId: sessionId ?? this.sessionId);
  }
}

class AuthService extends StateNotifier<AuthState> {
  late String _apiUrl;
  final EventNotifier<String> connectionNotifier = EventNotifier<String>();

  AuthService(Ref ref) : super(AuthState()) {
    _apiUrl = ref.read(serverUrlProvider);
  }

  String getSessionId() {
    return state.sessionId;
  }

  Future<String> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$_apiUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      _onSuccessfulAuth(data['session_token'] ?? "", email);
      return "";
    }

    int errorCode = data['error'] ?? 0;
    if (errorCode == 1) {
      return S.current.authServiceInvalidCredentials;
    } else if (errorCode == 2) {
      return S.current.authServiceUnknownAccount;
    }
    return S.current.authServiceUnknownError;
  }

  Future<AccountError> signup(
    String username,
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$_apiUrl/auth/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
      }),
    );
    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      _onSuccessfulAuth(data['sessionId'], username);
      return AccountError();
    }

    final loc = S.current;

    // TODO: Improve error messages to be more descriptive
    return AccountError(
      usernameError:
          data['usernameError'] == 1 ? loc.authServiceUsernameError : null,
      emailError: data['emailError'] == 1 ? loc.authServiceEmailError : null,
      passwordError:
          data['passwordError'] == 1 ? loc.authServicePasswordError : null,
    );
  }

  // TODO: Handle successful auth
  _onSuccessfulAuth(String sessionId, String username) {
    state = AuthState(sessionId: sessionId, username: username);
  }

  Map<String, String> addAuthHeader(Map<String, String> headers) {
    return {...headers, 'Authorization': 'Bearer ${state.sessionId}'};
  }
}
