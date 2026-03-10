class AuthState {
  final String sessionId;
  final int? userId;
  final String? email;
  final String? firstName;
  final String? lastName;

  bool get isAuthenticated => sessionId.isNotEmpty;
  AuthState({String? sessionId, this.userId, this.email, this.firstName, this.lastName})
    : sessionId = sessionId ?? "";

  AuthState copyWith({String? sessionId, int? userId, String? email, String? firstName, String? lastName}) {
    return AuthState(
      sessionId: sessionId ?? this.sessionId,
      userId: userId ?? this.userId,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
    );
  }
}