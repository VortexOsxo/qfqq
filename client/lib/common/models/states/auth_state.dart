import 'package:qfqq/common/models/user.dart';

class AuthState {
  final String sessionId;
  final User? user;

  bool get isAuthenticated => sessionId.isNotEmpty;
  AuthState({String? sessionId, this.user}) : sessionId = sessionId ?? "";

  AuthState copyWith({String? sessionId, User? user}) {
    return AuthState(
      sessionId: sessionId ?? this.sessionId,
      user: user ?? this.user,
    );
  }
}
