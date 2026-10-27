import 'package:flutter/material.dart';
import 'package:qfqq/common/pages/user_pages/signup_page_view_model.dart';
import 'package:qfqq/common/widgets/signup/signup_enter_code_widget.dart';
import 'package:qfqq/common/widgets/signup/signup_enter_details_widget.dart';
import 'package:qfqq/common/widgets/signup/signup_enter_email_widget.dart';

class SignupStepView extends StatelessWidget {
  final SignupPageViewModelState vm;

  const SignupStepView({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    if (vm.isLoading) {
      return Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (vm.loadingMessage != null) ...[
              Text(vm.loadingMessage!),
              const SizedBox(height: 12),
            ],
            const CircularProgressIndicator(),
          ],
        ),
      );
    }

    return switch (vm.step) {
      SignupStep.enterEmail => SignupEnterEmailWidget(vm: vm),
      SignupStep.enterCode => SignupEnterCodeWidget(vm: vm),
      SignupStep.enterDetails => SignupEnterDetailsWidget(vm: vm),
    };
  }
}
