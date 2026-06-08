import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/models/errors/account_error.dart';
import 'package:qfqq/common/models/user.dart';
import 'package:qfqq/common/providers/router_provider.dart';
import 'package:qfqq/common/services/auth_service.dart';
import 'package:qfqq/generated/l10n.dart';

class SignupPageViewModel extends ConsumerStatefulWidget {
  final Widget Function(SignupPageViewModelState vm) builder;

  const SignupPageViewModel({super.key, required this.builder});

  @override
  ConsumerState<SignupPageViewModel> createState() => SignupPageViewModelState();
}

class SignupPageViewModelState extends ConsumerState<SignupPageViewModel> {
  final formKey = GlobalKey<FormState>();

  User newUser = User(id: 0, firstName: '', lastName: '', email: '');
  String newPassword = '';
  String confirmPassword = '';
  AccountError error = AccountError();

  void submit() async {
    setState(() => error = AccountError());
    if (formKey.currentState?.validate() ?? false) {
      formKey.currentState?.save();

      if (newPassword != confirmPassword) {
        setState(
          () => error = AccountError(
            passwordError: S.of(context).commonFormsPasswordsDoNotMatch,
          ),
        );
        return;
      }

      final authService = ref.read(authStateProvider.notifier);
      final accountError = await authService.signup(newUser, newPassword);
      if (!mounted) return;

      if (accountError.getFirstError() != null) {
        setState(() => error = accountError);
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

  void saveEmail(String? val) => newUser.email = val ?? '';
  void saveFirstName(String? val) => newUser.firstName = val ?? '';
  void saveLastName(String? val) => newUser.lastName = val ?? '';
  void savePassword(String? val) => newPassword = val ?? '';
  void saveConfirmPassword(String? val) => confirmPassword = val ?? '';

  @override
  Widget build(BuildContext context) => widget.builder(this);
}
