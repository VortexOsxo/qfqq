import 'package:qfqq/generated/l10n.dart';

class AccountError {
  final String? firstNameError;
  final String? lastNameError;
  final String? emailError;
  final String? passwordError;
  final String? authError;

  AccountError({
    this.firstNameError,
    this.lastNameError,
    this.emailError,
    this.passwordError,
    this.authError,
  });

  String? getFirstError() {
    return firstNameError ?? lastNameError ?? emailError ?? passwordError ?? authError;
  }

  static AccountError fromJson(dynamic data) {
    final loc = S.current;

    return AccountError(
      firstNameError: data['firstName'] != null ? loc.authServiceFirstNameError : null,
      lastNameError: data['lastName'] != null ? loc.authServiceLastNameError : null,
      emailError: data['email'] != null ? loc.authServiceEmailError : null,
      passwordError: data['password'] != null ? loc.authServicePasswordError : null,
      authError: data['auth'] != null ? loc.authServiceInvalidCredentials : null,
    );
  }
}
