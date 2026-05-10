import 'package:qfqq/common/models/permissions.dart';
import 'package:qfqq/common/models/user.dart';

class AuthState {
  final String sessionId;
  final User? user;
  final Permissions? permissions;

  bool get isAuthenticated => sessionId.isNotEmpty;
  AuthState({String? sessionId, this.user, this.permissions}) : sessionId = sessionId ?? "";

  AuthState copyWith({String? sessionId, User? user}) {
    return AuthState(
      sessionId: sessionId ?? this.sessionId,
      user: user ?? this.user,
    );
  }
}
