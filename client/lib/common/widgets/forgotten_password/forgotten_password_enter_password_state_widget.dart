import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qfqq/common/services/forgotten_password_service.dart';
import 'package:qfqq/common/theme/styles.dart';
import 'package:qfqq/generated/l10n.dart';

class ForgottenPasswordEnterPasswordStateWidget extends ConsumerWidget {
  const ForgottenPasswordEnterPasswordStateWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var loc = S.of(context);

    var service = ref.read(forgottenPasswordStateProvider.notifier);
    var error = ref.watch(
      forgottenPasswordStateProvider.select((state) => state.errorMessage),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(loc.forgottenPasswordPageEnterNewPassword),
        TextField(
          decoration: InputDecoration(labelText: loc.attributePassword),
          onChanged: service.setPassword,
        ),
        SizedBox(height: 32),
        Text(loc.forgottenPasswordPageConfirmNewPassword),
        TextField(
          decoration: InputDecoration(labelText: loc.attributePassword),
          onChanged: service.setConfirmedPassword,
        ),
        if (error != null)
          Text(error, style: const TextStyle(color: Colors.red)),
        SizedBox(height: 8),
        ElevatedButton(
          style: squareButtonStyleSmall(context),
          onPressed: () async {
            var result = await service.updatePassword();
            if (result && context.mounted) {
              context.go('/login');
            }
          },
          child: Text(loc.forgottenPasswordPageResetPassword),
        ),
        SizedBox(height: 8),
        TextButton(
          onPressed: () => context.go('/login'),
          child: Text(loc.forgottenPasswordPageResendCodeLink),
        ),
        SizedBox(height: 8),
        TextButton(
          onPressed: () => context.go('/login'),
          child: Text(loc.forgottenPasswordPageLoginLink),
        ),
      ],
    );
  }
}
