import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:qfqq/common/models/errors/account_error.dart';
import 'package:qfqq/common/models/permissions.dart';
import 'package:qfqq/common/models/states/auth_state.dart';
import 'package:qfqq/common/models/user.dart';
import 'dart:convert';
import 'package:qfqq/common/utils/events/event_notifier.dart';
import 'package:qfqq/common/utils/storage.dart';
import 'package:qfqq/common/services/qfqq_http_client.dart';
import 'package:qfqq/common/services/session_token_store.dart';
import 'package:qfqq/generated/l10n.dart';

final authStateProvider = StateNotifierProvider<AuthService, AuthState>(
  (ref) => AuthService(
    ref.read(qfqqHttpClientProvider),
    ref.read(sessionTokenStoreProvider),
  ),
);

class AuthService extends StateNotifier<AuthState> {
  final EventNotifier<AuthState> connectionNotifier = EventNotifier();
  final EventNotifier<AuthState> disconnectionNotifier = EventNotifier();
  final QfqqHttpClient _httpClient;
  final SessionTokenStore _sessionTokenStore;

  AuthService(this._httpClient, this._sessionTokenStore) : super(AuthState());

  String getSessionId() => state.sessionId;
  bool isAuthenticated() => state.isAuthenticated;

  static Map<String, String> get _headers => { 'Content-Type': 'application/json' };

  static dynamic _safeJsonDecode(String body) {
    try {
      return jsonDecode(body);
    } catch (_) {
      return null;
    }
  }

  Future<AccountError> login(String email, String password, bool stay) async {
    http.Response response;
    try {
      response = await _httpClient.post(
        _httpClient.getUri('auth/login'),
        headers: _headers,
        body: jsonEncode({'email': email.toLowerCase().trim(), 'password': password}),
      );
    } on http.ClientException {
      return AccountError(authError: S.current.commonNetworkConnectionError);
    }

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

    final response = await _httpClient.post(
      _httpClient.getUri('auth/refresh'),
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
    http.Response response;
    try {
      response = await _httpClient.post(
        _httpClient.getUri('auth/signup'),
        headers: _headers,
        body: jsonEncode({
          'firstName': user.firstName,
          'lastName': user.lastName,
          'email': user.email.toLowerCase().trim(),
          'password': password,
        }),
      );
    } on http.ClientException {
      return AccountError(authError: S.current.commonNetworkConnectionError);
    }

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

    _sessionTokenStore.token = null;
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
    _sessionTokenStore.token = state.sessionId;
    connectionNotifier.notify(state);
  }
}
