import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qfqq/common/services/auth_service.dart';
import 'package:qfqq/common/utils/platform.dart';
import 'package:qfqq/generated/l10n.dart';

class NotFoundPage extends ConsumerWidget {
  const NotFoundPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = S.of(context);

    final isAuthenticated = ref.watch(authStateProvider.select((state) => state.isAuthenticated));

    final isMobile = platformType == PlatformType.mobile;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/background.png', width: isMobile ? 250 : 400),
            const SizedBox(height: 4),
            Text(loc.notFoundMessage, textAlign: TextAlign.center),
            TextButton(
              onPressed: () => context.go(isAuthenticated ? '/' : '/login'),
              child: Text(loc.commonBack),
            ),
          ],
        ),
      ),
    );
  }
}
