import 'package:qfqq/common/models/permissions.dart';
import 'package:qfqq/common/models/user.dart';

class AuthState {
  final String sessionId;
  final User? user;
  final String? orgStatus;
  final Permissions? permissions;

  bool get isAuthenticated => sessionId.isNotEmpty;
  bool get hasOrg => orgStatus != null;
  bool get hasOrgWithAccess => orgStatus == 'paidAccess' || orgStatus == 'freeTrialAccess';

  AuthState({
    String? sessionId,
    this.user,
    this.orgStatus,
    this.permissions,
  }) : sessionId = sessionId ?? "";
}
