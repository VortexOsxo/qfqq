import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/models/errors/account_error.dart';
import 'package:qfqq/common/models/user.dart';
import 'package:qfqq/common/providers/router_provider.dart';
import 'package:qfqq/common/services/auth_service.dart';
import 'package:qfqq/generated/l10n.dart';

enum SignupStep {
  enterEmail,
  enterCode,
  enterDetails,
}

class SignupPageViewModel extends ConsumerStatefulWidget {
  final Widget Function(SignupPageViewModelState vm) builder;

  const SignupPageViewModel({super.key, required this.builder});

  @override
  ConsumerState<SignupPageViewModel> createState() => SignupPageViewModelState();
}

class SignupPageViewModelState extends ConsumerState<SignupPageViewModel> {
  final formKey = GlobalKey<FormState>();

  SignupStep step = SignupStep.enterEmail;
  bool isLoading = false;
  String? loadingMessage;

  String email = '';
  String code = '';
  String firstName = '';
  String lastName = '';
  String newPassword = '';
  String confirmPassword = '';

  String? stepErrorMessage;
  AccountError accountError = AccountError();

  void setEmail(String val) => email = val;
  void setCode(String val) => code = val;
  void setFirstName(String val) => firstName = val;
  void setLastName(String val) => lastName = val;
  void setPassword(String val) => newPassword = val;
  void setConfirmPassword(String val) => confirmPassword = val;

  void saveFirstName(String? val) => firstName = val ?? '';
  void saveLastName(String? val) => lastName = val ?? '';
  void savePassword(String? val) => newPassword = val ?? '';
  void saveConfirmPassword(String? val) => confirmPassword = val ?? '';

  Future<void> requestCode() async {
    final trimmedEmail = email.trim();
    if (trimmedEmail.isEmpty) {
      setState(() => stepErrorMessage = S.of(context).commonFormsEnterEmail);
      return;
    }

    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(trimmedEmail)) {
      setState(() => stepErrorMessage = S.of(context).errorEmailInvalidFormat);
      return;
    }

    setState(() {
      isLoading = true;
      loadingMessage = S.of(context).signupPageRequestingCode;
      stepErrorMessage = null;
    });

    final authService = ref.read(authStateProvider.notifier);
    final result = await authService.requestEmailVerification(trimmedEmail);
    if (!mounted) return;

    if (result.error == null) {
      if (result.bypass) {
        setState(() {
          isLoading = false;
          code = '';
          step = SignupStep.enterDetails;
          stepErrorMessage = null;
        });
      } else {
        setState(() {
          isLoading = false;
          step = SignupStep.enterCode;
          stepErrorMessage = null;
        });
      }
    } else {
      setState(() {
        isLoading = false;
        stepErrorMessage = result.error;
      });
    }
  }

  Future<void> validateCode() async {
    final trimmedCode = code.trim();
    if (trimmedCode.isEmpty) {
      setState(() => stepErrorMessage = S.of(context).signupPageEnterCodeHint);
      return;
    }

    setState(() {
      isLoading = true;
      loadingMessage = S.of(context).signupPageValidatingCode;
      stepErrorMessage = null;
    });

    final authService = ref.read(authStateProvider.notifier);
    final error = await authService.validateEmailVerificationCode(email, trimmedCode);
    if (!mounted) return;

    if (error == null) {
      setState(() {
        isLoading = false;
        step = SignupStep.enterDetails;
        stepErrorMessage = null;
      });
    } else {
      setState(() {
        isLoading = false;
        stepErrorMessage = error;
      });
    }
  }

  void resendCode() {
    requestCode();
  }

  void changeEmail() {
    setState(() {
      code = '';
      stepErrorMessage = null;
      accountError = AccountError();
      step = SignupStep.enterEmail;
    });
  }

  void submit() async {
    setState(() {
      accountError = AccountError();
      stepErrorMessage = null;
    });

    if (formKey.currentState?.validate() ?? false) {
      formKey.currentState?.save();

      if (newPassword != confirmPassword) {
        setState(
          () => accountError = AccountError(
            passwordError: S.of(context).commonFormsPasswordsDoNotMatch,
          ),
        );
        return;
      }

      setState(() {
        isLoading = true;
        loadingMessage = null;
      });

      final authService = ref.read(authStateProvider.notifier);
      final user = User(
        id: 0,
        firstName: firstName.trim(),
        lastName: lastName.trim(),
        email: email.trim(),
      );

      final resultError = await authService.signup(user, newPassword, code.trim());
      if (!mounted) return;

      setState(() => isLoading = false);

      if (resultError.getFirstError() != null) {
        setState(() => accountError = resultError);
      } else {
        final authState = ref.read(authStateProvider);
        if (authState.hasOrg) {
          ref.read(routerProvider).go('/');
        } else {
          ref.read(routerProvider).go('/organizations/links');
        }
      }
    }
  }

  void goToLogin() => ref.read(routerProvider).go('/login');

  @override
  Widget build(BuildContext context) => widget.builder(this);
}
