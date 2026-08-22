import 'package:flutter/material.dart';
import 'package:qfqq/common/models/states/forgotten_password_state.dart';
import 'package:qfqq/common/pages/user_pages/forgotten_password_page_view_model.dart';
import 'package:qfqq/common/widgets/forgotten_password/forgotten_password_enter_code_state_widget.dart';
import 'package:qfqq/common/widgets/forgotten_password/forgotten_password_enter_email_state_widget.dart';
import 'package:qfqq/common/widgets/forgotten_password/forgotten_password_enter_password_state_widget.dart';

class ForgottenPasswordPage extends StatelessWidget {
  const ForgottenPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ForgottenPasswordPageViewModel(
      builder: (vm) => _ForgottenPasswordView(vm: vm),
    );
  }
}

class _ForgottenPasswordView extends StatelessWidget {
  final ForgottenPasswordPageViewModelState vm;
  const _ForgottenPasswordView({required this.vm});

  @override
  Widget build(BuildContext context) {
    if (vm.isLoading) {
      return Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Text(vm.loadingMessage ?? 'No loading message'),
            const SizedBox(height: 12,),
            const CircularProgressIndicator(),
          ],
        )
      );
    }

    var content = (switch (vm.step) {
      ForgottenPasswordStep.enterEmail =>
        ForgottenPasswordEnterEmailStateWidget(vm: vm),
      ForgottenPasswordStep.enterCode => ForgottenPasswordEnterCodeStateWidget(
        vm: vm,
      ),
      ForgottenPasswordStep.enterNewPassword =>
        ForgottenPasswordEnterPasswordStateWidget(vm: vm),
    });

    return Padding(
      padding: EdgeInsets.all(8),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 800.0, // Set your maximum width here
        ),
        child: content,
      ),
    );
  }
}
