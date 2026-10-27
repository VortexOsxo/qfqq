import 'package:flutter/material.dart';
import 'package:qfqq/common/pages/user_pages/signup_page_view_model.dart';
import 'package:qfqq/common/widgets/signup/signup_step_view.dart';
import 'package:qfqq/mobile/layouts/auth_page_layout.dart';

class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SignupPageViewModel(builder: (vm) => _MobileSignupView(vm: vm));
  }
}

class _MobileSignupView extends StatelessWidget {
  final SignupPageViewModelState vm;
  const _MobileSignupView({required this.vm});

  @override
  Widget build(BuildContext context) {
    return AuthPageLayout(child: SignupStepView(vm: vm));
  }
}
