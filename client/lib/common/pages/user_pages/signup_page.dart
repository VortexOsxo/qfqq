import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/models/errors/account_error.dart';
import 'package:qfqq/common/models/user.dart';
import 'package:qfqq/common/providers/router_provider.dart';
import 'package:qfqq/common/services/auth_service.dart';
import 'package:go_router/go_router.dart';
import 'package:qfqq/common/theme/styles.dart';
import 'package:qfqq/common/widgets/reusables/adaptive_layout.dart';
import 'package:qfqq/common/pages/user_pages/layouts/auth_desktop_layout.dart';
import 'package:qfqq/common/pages/user_pages/layouts/auth_mobile_layout.dart';
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
    final form = _SignupForm(
      formKey: _signupFormKey,
      onSubmit: _submitSignup,
      error: error,
      onEmailSaved: (v) => newUser.email = v ?? '',
      onFirstNameSaved: (v) => newUser.firstName = v ?? '',
      onLastNameSaved: (v) => newUser.lastName = v ?? '',
      onPasswordSaved: (v) => newPassword = v ?? '',
      onConfirmPasswordSaved: (v) => confirmPassword = v ?? '',
    );
    return AdaptiveLayout(
      mobile: (_) => AuthMobileLayout(child: form),
      desktop: (_) => AuthDesktopLayout(child: form),
    );
  }
}

class _SignupForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final VoidCallback onSubmit;
  final AccountError error;
  final ValueSetter<String?> onEmailSaved;
  final ValueSetter<String?> onFirstNameSaved;
  final ValueSetter<String?> onLastNameSaved;
  final ValueSetter<String?> onPasswordSaved;
  final ValueSetter<String?> onConfirmPasswordSaved;

  const _SignupForm({
    required this.formKey,
    required this.onSubmit,
    required this.error,
    required this.onEmailSaved,
    required this.onFirstNameSaved,
    required this.onLastNameSaved,
    required this.onPasswordSaved,
    required this.onConfirmPasswordSaved,
  });

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);
    return Form(
      key: formKey,
      child: Column(
        children: [
          TextFormField(
            decoration: InputDecoration(labelText: loc.attributeEmail, errorText: error.emailError),
            onSaved: onEmailSaved,
          ),
          const SizedBox(height: 8),
          TextFormField(
            decoration: InputDecoration(labelText: loc.attributeFirstName, errorText: error.firstNameError),
            onSaved: onFirstNameSaved,
          ),
          const SizedBox(height: 8),
          TextFormField(
            decoration: InputDecoration(labelText: loc.attributeLastName, errorText: error.lastNameError),
            onSaved: onLastNameSaved,
          ),
          const SizedBox(height: 8),
          TextFormField(
            decoration: InputDecoration(labelText: loc.attributePassword, errorText: error.passwordError),
            obscureText: true,
            onSaved: onPasswordSaved,
          ),
          const SizedBox(height: 8),
          TextFormField(
            decoration: InputDecoration(labelText: loc.signUpPageConfirmPassword, errorText: error.passwordError),
            obscureText: true,
            onSaved: onConfirmPasswordSaved,
          ),
          const SizedBox(height: 16),
          if (error.authError != null)
            Text(error.authError!, style: const TextStyle(color: Colors.red)),
          ElevatedButton(
            style: squareButtonStyle(context),
            onPressed: onSubmit,
            child: Text(loc.signupPageButtonSignup),
          ),
          const SizedBox(height: 32),
          TextButton(
            onPressed: () => context.go('/login'),
            child: Text(loc.signupPageLinkLogin),
          ),
        ],
      ),
    );
  }
}
