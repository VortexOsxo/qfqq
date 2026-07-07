import 'package:qfqq/generated/l10n.dart';

class OrgInviteErrors {
  String? emailError;

  OrgInviteErrors({this.emailError});

  bool hasAny() {
    return emailError != null;
  }

  OrgInviteErrors.fromJson(dynamic json) {
    if (json == null || json is! Map) return;

    if (json.containsKey('email')) {
      final code = json['email'] is int ? json['email'] as int : null;
      if (code == 2) {
        emailError = S.current.errorEmailInvalidFormat;
      } else if (code == 1) {
        emailError = S.current.commonFormsEnterEmail;
      } else {
        emailError = S.current.errorEmailUnknown;
      }
    }
  }
}
