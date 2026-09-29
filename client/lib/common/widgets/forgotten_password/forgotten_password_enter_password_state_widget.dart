import 'package:flutter/material.dart';
import 'package:qfqq/common/pages/user_pages/forgotten_password_page_view_model.dart';
import 'package:qfqq/common/theme/styles.dart';
import 'package:qfqq/common/widgets/reusables/password_text_field.dart';
import 'package:qfqq/generated/l10n.dart';

class ForgottenPasswordEnterPasswordStateWidget extends StatelessWidget {
  final ForgottenPasswordPageViewModelState vm;
  const ForgottenPasswordEnterPasswordStateWidget({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    var loc = S.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(loc.forgottenPasswordPageEnterNewPassword),
        PasswordTextField(
          decoration: InputDecoration(labelText: loc.attributePassword),
          onChanged: vm.setPassword,
        ),
        const SizedBox(height: 32),
        Text(loc.forgottenPasswordPageConfirmNewPassword),
        PasswordTextField(
          decoration: InputDecoration(labelText: loc.attributePassword),
          onChanged: vm.setConfirmedPassword,
        ),
        if (vm.errorMessage != null)
          Text(vm.errorMessage!, style: const TextStyle(color: Colors.red)),
        const SizedBox(height: 8),
        ElevatedButton(
          style: squareButtonStyleSmall(context),
          onPressed: vm.updatePassword,
          child: Text(loc.forgottenPasswordPageResetPassword),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: vm.resendCode,
          child: Text(loc.forgottenPasswordPageResendCodeLink),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: vm.goToLogin,
          child: Text(loc.forgottenPasswordPageLoginLink),
        ),
      ],
    );
  }
}
