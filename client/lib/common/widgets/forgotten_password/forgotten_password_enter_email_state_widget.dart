import 'package:flutter/material.dart';
import 'package:qfqq/common/pages/user_pages/forgotten_password_page_view_model.dart';
import 'package:qfqq/common/theme/styles.dart';
import 'package:qfqq/generated/l10n.dart';

class ForgottenPasswordEnterEmailStateWidget extends StatelessWidget {
  final ForgottenPasswordPageViewModelState vm;
  const ForgottenPasswordEnterEmailStateWidget({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    var loc = S.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(loc.forgottenPasswordPageEnterEmail),
        TextField(
          decoration: InputDecoration(labelText: loc.attributeEmail),
          onChanged: vm.setEmail,
        ),
        const SizedBox(height: 8),
        if (vm.errorMessage != null)
          Text(vm.errorMessage!, style: const TextStyle(color: Colors.red)),
        const SizedBox(height: 8),
        ElevatedButton(
          style: squareButtonStyleSmall(context),
          onPressed: vm.requestCode,
          child: Text(loc.forgottenPasswordPageResetPassword),
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
