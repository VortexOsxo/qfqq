import 'package:flutter/material.dart';
import 'package:qfqq/common/pages/user_pages/forgotten_password_page_view_model.dart';
import 'package:qfqq/common/theme/styles.dart';
import 'package:qfqq/generated/l10n.dart';

class ForgottenPasswordEnterCodeStateWidget extends StatelessWidget {
  final ForgottenPasswordPageViewModelState vm;
  const ForgottenPasswordEnterCodeStateWidget({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    var loc = S.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(loc.forgottenPasswordPageResetCodeSent),
        Text(vm.email),
        const SizedBox(height: 8),
        Text(loc.forgottenPasswordPageEnterCode),
        SizedBox(
          width: 180,
          child: TextField(
            maxLength: 6,
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              hintText: loc.forgottenPasswordPageEnterCodeHint,
              counterText: '',
            ),
            onChanged: vm.setCode,
          ),
        ),
        const SizedBox(height: 16),
        if (vm.errorMessage != null)
          Text(vm.errorMessage!, style: const TextStyle(color: Colors.red)),
        const SizedBox(height: 8),
        ElevatedButton(
          style: squareButtonStyleSmall(context),
          onPressed: vm.validateCode,
          child: Text(loc.forgottenPasswordPageConfirm),
        ),
        TextButton(
          onPressed: vm.resendCode,
          child: Text(loc.forgottenPasswordPageResendCodeLink),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: vm.goToLogin,
          child: Text(loc.forgottenPasswordPageLoginLink),
        ),
        const SizedBox(height: 100),
      ],
    );
  }
}
