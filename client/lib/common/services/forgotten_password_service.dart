import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/models/states/forgotten_password_state.dart';
import 'package:http/http.dart' as http;
import 'package:qfqq/generated/l10n.dart';

final forgottenPasswordStateProvider =
    StateNotifierProvider<ForgottenPasswordService, ForgottenPasswordState>(
      (_) => ForgottenPasswordService(),
    );

const _version = String.fromEnvironment("VERSION");

class ForgottenPasswordService extends StateNotifier<ForgottenPasswordState> {
  static const String _apiUrl = String.fromEnvironment("API_URL");
  String? password;
  String? confirmedPassword;

  ForgottenPasswordService() : super(ForgottenPasswordState.enterEmail());

  void setPassword(String password) {
    this.password = password;
  }

  void setConfirmedPassword(String password) {
    confirmedPassword = password;
  }

  void setEmail(String email) {
    state = state.copyWith(email: email);
  }

  void setCode(String code) {
    state = state.copyWith(code: code);
  }

  void reset() {
    state = ForgottenPasswordState.enterEmail();
  }

  Future<void> requestCode() async {
    state = state.copyWith(isLoading: true);
    final response = await http.post(
      Uri.parse('$_apiUrl/auth/forgotten-password/request-code'),
      headers: {'Content-Type': 'application/json', 'QfqqVersion': _version},
      body: jsonEncode({'email': state.email}),
    );
    if (response.statusCode == 204) {
      state = state.goToEnterCode();
      return;
    }

    final data = jsonDecode(response.body);
    int error = data['email'];

    String? errorMessage;

    // TODO: Translate

    if (error == 1) {
      errorMessage = 'Please enter your email';
    } else if (error == 2) {
      errorMessage = 'Please use a valid email format: abc@def.ghi';
    } else if (error == 10) {
      errorMessage =
          'There is no account associated with the email: ${state.email}';
    }
    state = state.copyWith(
      errorMessage: errorMessage ?? S.current.errorUnknown,
      isLoading: false
    );
  }

  Future<void> validateCode() async {
    state = state.copyWith(isLoading: true);
    final response = await http.post(
      Uri.parse('$_apiUrl/auth/forgotten-password/validate-code'),
      headers: {'Content-Type': 'application/json', 'QfqqVersion': _version},
      body: jsonEncode({'email': state.email, 'code': state.code}),
    );

    if (response.statusCode == 204) {
      password = null;
      confirmedPassword = null;
      state = state.goToEnterPassword();
    } else {
      state = state.copyWith(
        errorMessage: S.current.forgottenPasswordPageInvalidCode,
        isLoading: false
      );
    }
  }

  Future<bool> updatePassword() async {
    if (password == null || password!.isEmpty) {
      state = state.copyWith(errorMessage: S.current.commonFormsEnterPassword);
      return false;
    } else if (password != confirmedPassword) {
      state = state.copyWith(errorMessage: S.current.commonFormsPasswordsDoNotMatch);
      return false;
    }

    state = state.copyWith(isLoading: true);
    final response = await http.post(
      Uri.parse('$_apiUrl/auth/forgotten-password/update'),
      headers: {'Content-Type': 'application/json', 'QfqqVersion': _version},
      body: jsonEncode({
        'email': state.email,
        'code': state.code,
        'password': password,
      }),
    );

    if (response.statusCode == 204) {
      return true;
    }

    state = state.copyWith(errorMessage: S.current.forgottenPasswordPageExpiredWindow, isLoading: false);
    return false;
  }
}
