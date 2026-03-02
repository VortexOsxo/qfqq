import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/models/states/forgotten_password_state.dart';
import 'package:qfqq/common/services/forgotten_password_service.dart';
import 'package:qfqq/common/widgets/forgotten_password/forgotten_password_enter_code_state_widget.dart';
import 'package:qfqq/common/widgets/forgotten_password/forgotten_password_enter_email_state_widget.dart';
import 'package:qfqq/common/widgets/forgotten_password/forgotten_password_enter_password_state_widget.dart';

class ForgottenPasswordPage extends ConsumerWidget {
  const ForgottenPasswordPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var isLoading = ref.watch(
      forgottenPasswordStateProvider.select((state) => state.isLoading),
    );

    if (isLoading) {
      return Padding(
        padding: EdgeInsetsGeometry.all(8),
        child: CircularProgressIndicator(),
      );
    }

    var step = ref.watch(
      forgottenPasswordStateProvider.select((state) => state.step),
    );

    return switch (step) {
      ForgottenPasswordStep.enterEmail =>
        ForgottenPasswordEnterEmailStateWidget(),
      ForgottenPasswordStep.enterCode =>
        ForgottenPasswordEnterCodeStateWidget(),
      ForgottenPasswordStep.enterNewPassword =>
        ForgottenPasswordEnterPasswordStateWidget(),
    };
  }
}
