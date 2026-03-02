import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qfqq/common/services/forgotten_password_service.dart';
import 'package:qfqq/common/theme/styles.dart';
import 'package:qfqq/generated/l10n.dart';

class ForgottenPasswordEnterCodeStateWidget extends ConsumerWidget {
  const ForgottenPasswordEnterCodeStateWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var loc = S.of(context);

    var email = ref.read(
      forgottenPasswordStateProvider.select((value) => value.email),
    );
    var error = ref.watch(
      forgottenPasswordStateProvider.select((state) => state.errorMessage),
    );

    var service = ref.read(forgottenPasswordStateProvider.notifier);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(loc.forgottenPasswordPageResetCodeSent),
        Text(email),
        SizedBox(height: 8),
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
            onChanged: service.setCode,
          ),
        ),
        SizedBox(height: 16),
        if (error != null)
          Text(error, style: const TextStyle(color: Colors.red)),
        SizedBox(height: 8),
        ElevatedButton(
          style: squareButtonStyleSmall(context),
          onPressed: service.validateCode,
          child: Text(loc.forgottenPasswordPageConfirm),
        ),
        TextButton(
          onPressed: () {
            ref.read(forgottenPasswordStateProvider.notifier).reset();
            context.go('/forgotten-password');
          },
          child: Text(loc.forgottenPasswordPageResendCodeLink),
        ),
        SizedBox(height: 8),
        TextButton(
          onPressed: () => context.go('/login'),
          child: Text(loc.forgottenPasswordPageLoginLink),
        ),
        SizedBox(height: 100),
      ],
    );
  }
}
