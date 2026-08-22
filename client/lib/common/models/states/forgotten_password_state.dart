enum ForgottenPasswordStep {
  enterEmail,
  enterCode,
  enterNewPassword,
}

class ForgottenPasswordState {
  final ForgottenPasswordStep step;
  final bool isLoading;
  final int loadingTask;
  final String email;
  final String code;
  final String? errorMessage;

  const ForgottenPasswordState({
    required this.step,
    required this.isLoading,
    this.loadingTask = 0,
    required this.email,
    required this.code,
    required this.errorMessage,
  });

  factory ForgottenPasswordState.enterEmail() {
    return const ForgottenPasswordState(
      step: ForgottenPasswordStep.enterEmail,
      isLoading: false,
      email: '',
      code: '',
      errorMessage: null,
    );
  }

  ForgottenPasswordState goToEnterCode() {
    return ForgottenPasswordState(
      step: ForgottenPasswordStep.enterCode,
      isLoading: false,
      email: email,
      code: '',
      errorMessage: null,
    );
  }

  ForgottenPasswordState goToEnterPassword() {
    return ForgottenPasswordState(
      step: ForgottenPasswordStep.enterNewPassword,
      isLoading: false,
      email: email,
      code: code,
      errorMessage: null,
    );
  }

  ForgottenPasswordState copyWith({
    ForgottenPasswordStep? step,
    bool? isLoading,
    int? loadingTask,
    String? email,
    String? code,
    String? errorMessage,
  }) {
    return ForgottenPasswordState(
      step: step ?? this.step,
      isLoading: isLoading ?? this.isLoading,
      loadingTask: loadingTask ?? this.loadingTask,
      email: email ?? this.email,
      code: code ?? this.code,
      errorMessage: errorMessage,
    );
  }
}