import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/models/errors/account_error.dart';
import 'package:qfqq/common/models/user.dart';
import 'package:qfqq/common/providers/router_provider.dart';
import 'package:qfqq/common/services/auth_service.dart';
import 'package:go_router/go_router.dart';
import 'package:qfqq/common/theme/styles.dart';
import 'package:qfqq/generated/l10n.dart';

class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({super.key});

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  final _signupFormKey = GlobalKey<FormState>();

  User newUser = User(id: 0, firstName: '', lastName: '', email: '');
  String newPassword = '';
  String confirmPassword = ''; 
  AccountError error = AccountError();

  void _submitSignup() async {
    setState(() => error = AccountError());
    if (_signupFormKey.currentState?.validate() ?? false) {
      _signupFormKey.currentState?.save();

      if (newPassword != confirmPassword) {
        setState(
          () =>
              error = AccountError(
                passwordError: S.of(context).commonFormsPasswordsDoNotMatch,
              )
        );
        return;
      }

      final authService = ref.read(authStateProvider.notifier);
      final accountError = await authService.signup(newUser, newPassword);
      if (!mounted) return;

      if (accountError.getFirstError() != null) {
        setState(() => error = accountError);
      } else {
        ref.read(routerProvider).go('/');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);

    return Form(
      key: _signupFormKey,
      child: Column(
        children: [
          TextFormField(
            decoration: InputDecoration(
              labelText: loc.attributeEmail,
              errorText: error.emailError,
            ),
            onSaved: (val) => newUser.email = val ?? '',
          ),
          const SizedBox(height: 8),
          TextFormField(
            decoration: InputDecoration(
              labelText: loc.attributeFirstName,
              errorText: error.firstNameError,
            ),
            onSaved: (val) => newUser.firstName = val ?? '',
          ),
          const SizedBox(height: 8),
          TextFormField(
            decoration: InputDecoration(
              labelText: loc.attributeLastName,
              errorText: error.lastNameError,
            ),
            onSaved: (val) => newUser.lastName = val ?? '',
          ),
          const SizedBox(height: 8),
          TextFormField(
            decoration: InputDecoration(
              labelText: loc.attributePassword,
              errorText: error.passwordError,
            ),
            obscureText: true,
            onSaved: (val) => newPassword = val ?? '',
          ),
          const SizedBox(height: 8),
          TextFormField(
            decoration: InputDecoration(
              labelText: loc.signUpPageConfirmPassword,
              errorText: error.passwordError,
            ),
            obscureText: true,
            onSaved: (val) => confirmPassword = val ?? '',
          ),
          const SizedBox(height: 16),
          if (error.authError != null)
            Text(error.authError!, style: const TextStyle(color: Colors.red)),
          Align(
            alignment: Alignment.center,
            child: ElevatedButton(
              style: squareButtonStyle(context),
              onPressed: _submitSignup,
              child: Text(loc.signupPageButtonSignup),
            ),
          ),
          SizedBox(height: 32),
          Align(
            alignment: Alignment.center,
            child: TextButton(
              onPressed: () => context.go('/login'),
              child: Text(loc.signupPageLinkLogin),
            ),
          ),
        ],
      ),
    );
  }
}
