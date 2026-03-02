class AuthState {
  final String sessionId;
  final String? email;
  final String? username;

  bool get isAuthenticated => sessionId.isNotEmpty;
  AuthState({String? sessionId, this.email, this.username})
    : sessionId = sessionId ?? "";

  AuthState copyWith({String? sessionId, String? email, String? username}) {
    return AuthState(
      sessionId: sessionId ?? this.sessionId,
      email: email ?? this.email,
      username: username ?? this.username,
    );
  }
}