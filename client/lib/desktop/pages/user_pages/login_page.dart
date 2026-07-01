import 'package:flutter/material.dart';
import 'package:qfqq/common/pages/user_pages/login_page_view_model.dart';
import 'package:qfqq/common/theme/styles.dart';
import 'package:qfqq/desktop/layouts/auth_page_layout.dart';
import 'package:qfqq/generated/l10n.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LoginPageViewModel(builder: (vm) => _DesktopLoginView(vm: vm));
  }
}

class _DesktopLoginView extends StatelessWidget {
  final LoginPageViewModelState vm;
  const _DesktopLoginView({required this.vm});

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);

    return AuthPageLayout(
      child: Form(
        key: vm.formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              decoration: InputDecoration(labelText: loc.attributeEmail),
              onSaved: vm.saveEmail,
            ),
            const SizedBox(height: 8),
            TextFormField(
              decoration: InputDecoration(labelText: loc.attributePassword),
              obscureText: true,
              onSaved: vm.savePassword,
            ),
            const SizedBox(height: 8),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              value: vm.stay,
              onChanged: vm.saveStay,
              title: Text(
                loc.loginPageStayLoggedIn,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 16),
            if (vm.error.isNotEmpty)
              Text(vm.error, style: const TextStyle(color: Colors.red)),
            ElevatedButton(
              style: squareButtonStyle(context),
              onPressed: vm.submit,
              child: Text(loc.loginPageButtonLogin),
            ),
            const SizedBox(height: 32),
            TextButton(
              onPressed: vm.goToSignup,
              child: Text(loc.loginPageLinkSignup),
            ),
            TextButton(
              onPressed: vm.goToCreateOrganization,
              child: Text(loc.loginPageLinkCreateOrganization),
            ),
            TextButton(
              onPressed: vm.goToForgottenPassword,
              child: Text(loc.loginPageForgottenPasswordLink),
            ),
          ],
        ),
      ),
    );
  }
}
