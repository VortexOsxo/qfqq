import 'package:qfqq/common/models/permissions.dart';
import 'package:qfqq/common/models/user.dart';

class AuthState {
  final String sessionId;
  final User? user;
  final bool hasOrg;
  final Permissions? permissions;

  bool get isAuthenticated => sessionId.isNotEmpty;
  AuthState({String? sessionId, this.user, bool? hasOrg, this.permissions})
    : sessionId = sessionId ?? "",
      hasOrg = hasOrg ?? false;
}
