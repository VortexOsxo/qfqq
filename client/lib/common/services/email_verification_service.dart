import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/models/states/email_verification_state.dart';
import 'package:qfqq/common/services/qfqq_http_client.dart';
import 'package:qfqq/generated/l10n.dart';

final emailVerificationStateProvider =
    StateNotifierProvider<EmailVerificationService, EmailVerificationState>(
      (ref) => EmailVerificationService(ref.read(qfqqHttpClientProvider)),
    );

class EmailVerificationService extends StateNotifier<EmailVerificationState> {
  final QfqqHttpClient _httpClient;

  EmailVerificationService(this._httpClient)
    : super(EmailVerificationState(isLoading: false, errorMessage: null));

  void setCode(String code) {
    state = state.copyWith(code: code);
  }

  void reset() {
    state = EmailVerificationState(isLoading: false, errorMessage: null);
  }

  Future<void> requestCode() async {
    state = state.copyWith(isLoading: true);
    final response = await _httpClient.post(
      _httpClient.getUri('auth/email-verification/request-code'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 204) {
      state = state.copyWith(isLoading: false);
      return;
    }

    state = state.copyWith(
      errorMessage: _errorMessage(response.body),
      isLoading: false,
    );
  }

  Future<bool> validateCode() async {
    state = state.copyWith(isLoading: true);
    final response = await _httpClient.post(
      _httpClient.getUri('auth/email-verification/validate-code'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'code': state.code}),
    );

    if (response.statusCode == 204) {
      state = state.copyWith(isLoading: false);
      return true;
    }

    state = state.copyWith(
      errorMessage: S.current.emailVerificationPageInvalidCode,
      isLoading: false,
    );
    return false;
  }

  String _errorMessage(String body) => S.current.errorUnknown;
}
