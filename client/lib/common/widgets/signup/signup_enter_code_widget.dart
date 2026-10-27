import 'package:flutter/material.dart';
import 'package:qfqq/common/pages/user_pages/signup_page_view_model.dart';
import 'package:qfqq/common/theme/styles.dart';
import 'package:qfqq/generated/l10n.dart';

class SignupEnterCodeWidget extends StatelessWidget {
  final SignupPageViewModelState vm;
  const SignupEnterCodeWidget({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          loc.signupPageCodeSent,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          vm.email,
          style: const TextStyle(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: 180,
          child: TextFormField(
            initialValue: vm.code,
            maxLength: 6,
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              hintText: loc.signupPageEnterCodeHint,
              counterText: '',
            ),
            onChanged: vm.setCode,
            onFieldSubmitted: (_) => vm.validateCode(),
          ),
        ),
        const SizedBox(height: 16),
        if (vm.stepErrorMessage != null)
          Text(
            vm.stepErrorMessage!,
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
        const SizedBox(height: 16),
        ElevatedButton(
          style: squareButtonStyle(context),
          onPressed: vm.validateCode,
          child: Text(loc.signupPageValidateCode),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: vm.resendCode,
          child: Text(loc.signupPageResendCodeLink),
        ),
        TextButton(
          onPressed: vm.changeEmail,
          child: Text(loc.signupPageChangeEmailLink),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: vm.goToLogin,
          child: Text(loc.signupPageLinkLogin),
        ),
      ],
    );
  }
}
