class EmailVerificationState {
  final bool isLoading;
  final String code;
  final String? errorMessage;

  const EmailVerificationState({
    required this.isLoading,
    this.code = '',
    this.errorMessage,
  });

  EmailVerificationState copyWith({
    bool? isLoading,
    String? code,
    String? errorMessage,
  }) {
    return EmailVerificationState(
      isLoading: isLoading ?? this.isLoading,
      code: code ?? this.code,
      errorMessage: errorMessage,
    );
  }
}
