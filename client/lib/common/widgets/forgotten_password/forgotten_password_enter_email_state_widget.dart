import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qfqq/common/services/forgotten_password_service.dart';
import 'package:qfqq/common/theme/styles.dart';
import 'package:qfqq/generated/l10n.dart';

class ForgottenPasswordEnterEmailStateWidget extends ConsumerWidget {
  const ForgottenPasswordEnterEmailStateWidget({super.key});

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
        Text(loc.forgottenPasswordPageEnterEmail),
        TextField(
          decoration: InputDecoration(labelText: loc.attributeEmail),
          onChanged: service.setEmail,
        ),
        SizedBox(height: 8),
        if (error != null)
          Text(error, style: const TextStyle(color: Colors.red)),
        SizedBox(height: 8),
        ElevatedButton(
          style: squareButtonStyleSmall(context),
          onPressed: service.requestCode,
          child: Text(loc.forgottenPasswordPageResetPassword),
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
