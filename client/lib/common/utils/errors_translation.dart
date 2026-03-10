import 'package:qfqq/generated/l10n.dart';

const int requiredField = 1;
const int maxLengthExceeded = 12;

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
