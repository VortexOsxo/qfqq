import 'package:flutter/material.dart';
import 'package:qfqq/common/pages/user_pages/signup_page_view_model.dart';
import 'package:qfqq/common/theme/styles.dart';
import 'package:qfqq/generated/l10n.dart';
import 'package:qfqq/mobile/layouts/auth_page_layout.dart';

class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SignupPageViewModel(builder: (vm) => _MobileSignupView(vm: vm));
  }
}

class _MobileSignupView extends StatelessWidget {
  final SignupPageViewModelState vm;
  const _MobileSignupView({required this.vm});

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);

    final form = Form(
        key: vm.formKey,
        child: Column(
          children: [
            TextFormField(
              decoration: InputDecoration(
                labelText: loc.attributeEmail,
                errorText: vm.error.emailError,
              ),
              onSaved: vm.saveEmail,
            ),
            const SizedBox(height: 8),
            TextFormField(
              decoration: InputDecoration(
                labelText: loc.attributeFirstName,
                errorText: vm.error.firstNameError,
              ),
              onSaved: vm.saveFirstName,
            ),
            const SizedBox(height: 8),
            TextFormField(
              decoration: InputDecoration(
                labelText: loc.attributeLastName,
                errorText: vm.error.lastNameError,
              ),
              onSaved: vm.saveLastName,
            ),
            const SizedBox(height: 8),
            TextFormField(
              decoration: InputDecoration(
                labelText: loc.attributePassword,
                errorText: vm.error.passwordError,
              ),
              obscureText: true,
              onSaved: vm.savePassword,
            ),
            const SizedBox(height: 8),
            TextFormField(
              decoration: InputDecoration(
                labelText: loc.signUpPageConfirmPassword,
                errorText: vm.error.passwordError,
              ),
              obscureText: true,
              onSaved: vm.saveConfirmPassword,
            ),
            const SizedBox(height: 16),
            if (vm.error.authError != null)
              Text(
                vm.error.authError!,
                style: const TextStyle(color: Colors.red),
              ),
            Align(
              alignment: Alignment.center,
              child: ElevatedButton(
                style: squareButtonStyle(context),
                onPressed: vm.submit,
                child: Text(loc.signupPageButtonSignup),
              ),
            ),
            const SizedBox(height: 32),
            Align(
              alignment: Alignment.center,
              child: TextButton(
                onPressed: vm.goToLogin,
                child: Text(loc.signupPageLinkLogin),
              ),
            ),
          ],
        ),
      );

    return AuthPageLayout(child: form);
  }
}
