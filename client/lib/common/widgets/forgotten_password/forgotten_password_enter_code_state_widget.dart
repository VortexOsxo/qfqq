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
    final loc = S.of(context);
    final email = ref.read(
      forgottenPasswordStateProvider.select((value) => value.email),
    );
    final error = ref.watch(
      forgottenPasswordStateProvider.select((state) => state.errorMessage),
    );
    final service = ref.read(forgottenPasswordStateProvider.notifier);

    final content = Column(
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
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 600) {
          return _DesktopLayout(child: content);
        }
        return _MobileLayout(child: content);
      },
    );
  }
}

class _MobileLayout extends StatelessWidget {
  final Widget child;
  const _MobileLayout({required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: child,
    );
  }
}

class _DesktopLayout extends StatelessWidget {
  final Widget child;
  const _DesktopLayout({required this.child});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            color: Theme.of(context).colorScheme.primary,
            child: Center(
              child: Text(
                'QFQQ',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: child,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
