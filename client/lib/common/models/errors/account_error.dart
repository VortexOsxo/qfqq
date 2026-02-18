import 'package:qfqq/generated/l10n.dart';

class AccountError {
  final String? usernameError;
  final String? emailError;
  final String? passwordError;
  final String? authError;

  AccountError({
    this.usernameError,
    this.emailError,
    this.passwordError,
    this.authError,
  });

  String? getFirstError() {
    return usernameError ?? emailError ?? passwordError ?? authError;
  }

  static AccountError fromJson(dynamic data) {
    final loc = S.current;

    return AccountError(
      usernameError: data['username'] != null ? loc.authServiceUsernameError : null,
      emailError: data['email'] != null ? loc.authServiceEmailError : null,
      passwordError: data['password'] != null ? loc.authServicePasswordError : null,
      authError: data['auth'] != null ? loc.authServiceInvalidCredentials : null,
    );
  }
}
