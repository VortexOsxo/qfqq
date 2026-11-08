import 'package:qfqq/common/utils/errors_translation.dart';
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
      final rawCode = json['email'];
      final code = rawCode is int ? rawCode : int.tryParse(rawCode?.toString() ?? '');
      if (code == invalidFormat) {
        emailError = S.current.errorEmailInvalidFormat;
      } else if (code == requiredField) {
        emailError = S.current.commonFormsEnterEmail;
      } else if (code == userAlreadyInOurOrganization) {
        emailError = S.current.organizationInviteUserAlreadyInOurOrganization;
      } else if (code == userAlreadyInOtherOrganization) {
        emailError = S.current.organizationInviteUserAlreadyInOtherOrganization;
      } else if (code == userAlreadyInvited) {
        emailError = S.current.organizationInviteUserAlreadyInvited;
      } else if (code == userAlreadyInvitedToOtherOrganization) {
        emailError = S.current.organizationInviteUserAlreadyInvitedToOtherOrganization;
      } else {
        emailError = S.current.errorEmailUnknown;
      }
    }
  }
}
