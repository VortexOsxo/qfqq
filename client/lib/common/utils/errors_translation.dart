import 'package:qfqq/generated/l10n.dart';

const int requiredField = 1;
const int invalidFormat = 2;
const int maxLengthExceeded = 12;
const int minLengthExceeded = 13;
const int userAlreadyInOurOrganization = 17;
const int userAlreadyInOtherOrganization = 18;
const int userAlreadyInvited = 19;
const int userAlreadyInvitedToOurOrganization = 19;
const int userAlreadyInvitedToOtherOrganization = 20;

String? translateNameError(int? error) {
  var loc = S.current;

  if (error == null) return null;

  if (error == requiredField) {
    return loc.errorRequiredField;
  }

  if (error == maxLengthExceeded) {
    return loc.errorNameMaxLength;
  }

  return loc.errorUnknown;
}

String? translatePasswordError(int? error) {
  var loc = S.current;

  if (error == null) return null;

  if (error == requiredField) {
    return loc.errorRequiredField;
  }

  if (error == maxLengthExceeded) {
    return loc.errorPasswordMaxLength;
  }

  if (error == minLengthExceeded) {
    return loc.errorPasswordMinLength;
  }

  if (error == invalidFormat) {
    return loc.errorPasswordInvalidFormat;
  }

  return loc.errorUnknown;
}
