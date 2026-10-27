import 'package:flutter/material.dart';
import 'package:qfqq/common/pages/user_pages/signup_page_view_model.dart';
import 'package:qfqq/common/theme/styles.dart';
import 'package:qfqq/common/widgets/reusables/password_text_field.dart';
import 'package:qfqq/generated/l10n.dart';

class SignupEnterDetailsWidget extends StatelessWidget {
  final SignupPageViewModelState vm;
  const SignupEnterDetailsWidget({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);

    return Form(
      key: vm.formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            initialValue: vm.email,
            readOnly: true,
            canRequestFocus: false,
            enableInteractiveSelection: false,
            decoration: InputDecoration(
              labelText: loc.attributeEmail,
            ),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: vm.firstName,
            decoration: InputDecoration(
              labelText: loc.attributeFirstName,
              errorText: vm.accountError.firstNameError,
            ),
            onChanged: vm.setFirstName,
            onSaved: vm.saveFirstName,
          ),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: vm.lastName,
            decoration: InputDecoration(
              labelText: loc.attributeLastName,
              errorText: vm.accountError.lastNameError,
            ),
            onChanged: vm.setLastName,
            onSaved: vm.saveLastName,
          ),
          const SizedBox(height: 8),
          PasswordTextField(
            decoration: InputDecoration(
              labelText: loc.attributePassword,
              errorText: vm.accountError.passwordError,
            ),
            onChanged: vm.setPassword,
            onSaved: vm.savePassword,
          ),
          const SizedBox(height: 8),
          PasswordTextField(
            decoration: InputDecoration(
              labelText: loc.signUpPageConfirmPassword,
              errorText: vm.accountError.passwordError,
            ),
            onChanged: vm.setConfirmPassword,
            onSaved: vm.saveConfirmPassword,
          ),
          const SizedBox(height: 16),
          if (vm.accountError.authError != null)
            Text(
              vm.accountError.authError!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          if (vm.accountError.codeError != null)
            Text(
              vm.accountError.codeError!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          const SizedBox(height: 16),
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
  }
}
