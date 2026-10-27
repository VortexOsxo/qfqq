import 'package:flutter/material.dart';
import 'package:qfqq/common/pages/user_pages/signup_page_view_model.dart';
import 'package:qfqq/common/widgets/signup/signup_step_view.dart';
import 'package:qfqq/desktop/layouts/auth_page_layout.dart';

class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SignupPageViewModel(builder: (vm) => _DesktopSignupView(vm: vm));
  }
}

class _DesktopSignupView extends StatelessWidget {
  final SignupPageViewModelState vm;
  const _DesktopSignupView({required this.vm});

  @override
  Widget build(BuildContext context) {
    return AuthPageLayout(child: SignupStepView(vm: vm));
  }
}
