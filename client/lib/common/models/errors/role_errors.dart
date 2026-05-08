import 'package:qfqq/generated/l10n.dart';

class RoleErrors {
  String? nameError;


  RoleErrors({this.nameError});

  bool hasAny() {
    return nameError != null;
  }

  RoleErrors.fromJson(dynamic json) {
    if (json == null || json is! Map) return;

    var loc = S.current;
    if (json.containsKey('name')) {
      nameError = json['name'] == 14 ? loc.createRoleFormUniqueName : loc.commonFormsEnterName;
    }
  }
}
