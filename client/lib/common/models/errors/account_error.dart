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
    if (usernameError != null) {
      return usernameError;
    } else if (emailError != null) {
      return emailError;
    } else if (passwordError != null) {
      return passwordError;
    } else if (authError != null) {
      return authError;
    }
    return null;
  }

  static AccountError fromJson(dynamic data) {
    final loc = S.current;

    int? usernameErrorCode = data['username'];
    int? emailErrorCode = data['email'];
    int? passwordErrorCode = data['password'];
    int? authErrorCode = data['auth'];

    return AccountError(
      usernameError: usernameErrorCode != null ? loc.authServiceUsernameError : null,
      emailError: emailErrorCode != null ? loc.authServiceEmailError : null,
      passwordError: passwordErrorCode != null ? loc.authServicePasswordError : null,
      authError: authErrorCode != null ? loc.authServiceInvalidCredentials : null,
    );
  }
}
