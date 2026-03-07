class AuthState {
  final String sessionId;
  final int? userId;
  final String? email;
  final String? username;

  bool get isAuthenticated => sessionId.isNotEmpty;
  AuthState({String? sessionId, this.userId, this.email, this.username})
    : sessionId = sessionId ?? "";

  AuthState copyWith({String? sessionId, int? userId, String? email, String? username}) {
    return AuthState(
      sessionId: sessionId ?? this.sessionId,
      userId: userId ?? this.userId,
      email: email ?? this.email,
      username: username ?? this.username,
    );
  }
}