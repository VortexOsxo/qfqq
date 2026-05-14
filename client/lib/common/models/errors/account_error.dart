import 'package:qfqq/common/utils/errors_translation.dart';
import 'package:qfqq/generated/l10n.dart';

class AccountError {
  final String? firstNameError;
  final String? lastNameError;
  final String? emailError;
  final String? passwordError;
  final String? authError;
  final String? slugError;

  AccountError({
    this.firstNameError,
    this.lastNameError,
    this.emailError,
    this.passwordError,
    this.authError,
    this.slugError,
  });

  String? getFirstError() {
    return firstNameError ??
        lastNameError ??
        emailError ??
        passwordError ??
        authError ??
        slugError;
  }

  static AccountError fromJson(dynamic data) {
    final loc = S.current;

    return AccountError(
      firstNameError: translateNameError(data['firstName']),
      lastNameError: translateNameError(data['lastName']),
      emailError: data['email'] != null ? loc.authServiceEmailError : null,
      passwordError: translatePasswordError(data['password']),
      authError: data['auth'] != null ? loc.authServiceInvalidCredentials : null,
      slugError: data['slug'] != null ? loc.errorRequiredField : null,
    );
  }
}
