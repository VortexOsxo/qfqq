import 'package:flutter/material.dart';
import 'package:qfqq/common/pages/user_pages/signup_page_view_model.dart';
import 'package:qfqq/common/theme/styles.dart';
import 'package:qfqq/generated/l10n.dart';

class SignupEnterEmailWidget extends StatelessWidget {
  final SignupPageViewModelState vm;
  const SignupEnterEmailWidget({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          initialValue: vm.email,
          decoration: InputDecoration(
            labelText: loc.attributeEmail,
            errorText: vm.stepErrorMessage,
          ),
          keyboardType: TextInputType.emailAddress,
          onChanged: vm.setEmail,
          onFieldSubmitted: (_) => vm.requestCode(),
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.center,
          child: ElevatedButton(
            style: squareButtonStyle(context),
            onPressed: vm.requestCode,
            child: Text(loc.signupPageSendCode),
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
    );
  }
}
