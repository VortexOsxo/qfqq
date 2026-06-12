import 'package:qfqq/common/models/role.dart';
import 'package:qfqq/common/utils/string.dart';
import 'package:qfqq/generated/l10n.dart';

String formatRoleName(Role role) {
  final loc = S.current;
  if (role.id == 1) {
    return loc.roleNameMember;
  } else if (role.id == 2) {
    return loc.roleNameAdmin;
  }

  return capitalize(role.name);
}
