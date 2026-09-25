import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qfqq/common/services/auth_service.dart';
import 'package:qfqq/generated/l10n.dart';

class ReturnLoginWidget extends ConsumerWidget {
  const ReturnLoginWidget({super.key});

  goBackToLogin(BuildContext context, WidgetRef ref) async {
    final service = ref.read(authStateProvider.notifier);
    await service.logout();

    if (context.mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = S.of(context);

    return TextButton(
      onPressed: () => goBackToLogin(context, ref),
      child: Text(loc.commonBack),
    );
  }
}
