import 'package:flutter_riverpod/flutter_riverpod.dart';
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

class RequestEmailVerificationResult {
  final bool bypass;
  final String? error;

  const RequestEmailVerificationResult({this.bypass = false, this.error});
}

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
    final response = await _httpClient.post(
      _httpClient.getUri('auth/login'),
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

  Future<RequestEmailVerificationResult> requestEmailVerification(String email) async {
    final response = await _httpClient.post(
      _httpClient.getUri('auth/email-verification/request-code'),
      headers: _headers,
      body: jsonEncode({'email': email.toLowerCase().trim()}),
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      final data = _safeJsonDecode(response.body);
      final bypass = data is Map && data['bypass'] == true;
      return RequestEmailVerificationResult(bypass: bypass);
    }

    final data = _safeJsonDecode(response.body);
    if (data is Map && data['email'] != null) {
      return RequestEmailVerificationResult(error: S.current.authServiceEmailError);
    }
    return RequestEmailVerificationResult(error: S.current.commonServerError);
  }

  Future<String?> validateEmailVerificationCode(String email, String code) async {
    final response = await _httpClient.post(
      _httpClient.getUri('auth/email-verification/validate-code'),
      headers: _headers,
      body: jsonEncode({
        'email': email.toLowerCase().trim(),
        'code': code.trim(),
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      return null;
    }

    return S.current.signupPageInvalidCode;
  }

  Future<AccountError> signup(User user, String password, String code) async {
    final response = await _httpClient.post(
      _httpClient.getUri('auth/signup'),
      headers: _headers,
      body: jsonEncode({
        'firstName': user.firstName,
        'lastName': user.lastName,
        'email': user.email.toLowerCase().trim(),
        'password': password,
        'code': code.trim(),
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

  Future<void> logout() async {
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
