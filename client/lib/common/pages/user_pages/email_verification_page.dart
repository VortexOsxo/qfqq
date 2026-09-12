import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qfqq/common/services/auth_service.dart';
import 'package:qfqq/common/services/email_verification_service.dart';
import 'package:qfqq/common/theme/styles.dart';
import 'package:qfqq/generated/l10n.dart';

class EmailVerificationPage extends ConsumerStatefulWidget {
  const EmailVerificationPage({super.key});

  @override
  ConsumerState<EmailVerificationPage> createState() =>
      _EmailVerificationPageState();
}

class _EmailVerificationPageState extends ConsumerState<EmailVerificationPage> {
  bool get isLoading => ref.watch(
    emailVerificationStateProvider.select((state) => state.isLoading),
  );

  String? get errorMessage => ref.watch(
    emailVerificationStateProvider.select((state) => state.errorMessage),
  );

  @override
  void initState() {
    super.initState();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      var service = ref.read(emailVerificationStateProvider.notifier);
      service.reset();
      service.requestCode();
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);
    final service = ref.read(emailVerificationStateProvider.notifier);

    return Padding(
      padding: const EdgeInsets.all(8),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: isLoading
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(loc.emailVerificationPageWaitingToSend),
                  const SizedBox(height: 12),
                  const CircularProgressIndicator(),
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(loc.emailVerificationPageCodeSent),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: 180,
                    child: TextField(
                      maxLength: 6,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        hintText: loc.emailVerificationPageEnterCodeHint,
                        counterText: '',
                      ),
                      onChanged: service.setCode,
                    ),
                  ),
                  if (errorMessage != null)
                    Text(
                      errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    style: squareButtonStyleSmall(context),
                    onPressed: () async {
                      final verified = await service.validateCode();
                      if (!verified || !mounted || !context.mounted) {
                        return;
                      }
                      ref.read(authStateProvider).user?.isVerified = true;
                      context.go('/profile');
                    },
                    child: Text(loc.emailVerificationPageConfirm),
                  ),
                ],
              ),
      ),
    );
  }
}