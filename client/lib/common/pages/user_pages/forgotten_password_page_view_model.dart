import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/models/states/forgotten_password_state.dart';
import 'package:qfqq/common/providers/router_provider.dart';
import 'package:qfqq/common/services/forgotten_password_service.dart';

class ForgottenPasswordPageViewModel extends ConsumerStatefulWidget {
  final Widget Function(ForgottenPasswordPageViewModelState vm) builder;

  const ForgottenPasswordPageViewModel({super.key, required this.builder});

  @override
  ConsumerState<ForgottenPasswordPageViewModel> createState() => ForgottenPasswordPageViewModelState();
}

class ForgottenPasswordPageViewModelState extends ConsumerState<ForgottenPasswordPageViewModel> {
  ForgottenPasswordStep get step => ref.watch(forgottenPasswordStateProvider.select((s) => s.step));

  bool get isLoading => ref.watch(forgottenPasswordStateProvider.select((s) => s.isLoading));

  String get email => ref.watch(forgottenPasswordStateProvider.select((s) => s.email));

  String? get errorMessage => ref.watch(forgottenPasswordStateProvider.select((s) => s.errorMessage));

  // ── Enter-email step ────────────────────────────────────────────────────
  void setEmail(String val) => ref.read(forgottenPasswordStateProvider.notifier).setEmail(val);

  void requestCode() => ref.read(forgottenPasswordStateProvider.notifier).requestCode();

  // ── Enter-code step ─────────────────────────────────────────────────────
  void setCode(String val) => ref.read(forgottenPasswordStateProvider.notifier).setCode(val);

  void validateCode() => ref.read(forgottenPasswordStateProvider.notifier).validateCode();

  void resendCode() {
    ref.read(forgottenPasswordStateProvider.notifier).reset();
    ref.read(routerProvider).go('/forgotten-password');
  }

  // ── Enter-password step ─────────────────────────────────────────────────
  void setPassword(String val) => ref.read(forgottenPasswordStateProvider.notifier).setPassword(val);

  void setConfirmedPassword(String val) => ref.read(forgottenPasswordStateProvider.notifier).setConfirmedPassword(val);

  void updatePassword() async {
    final result = await ref.read(forgottenPasswordStateProvider.notifier).updatePassword();
    if (result && mounted) {
      ref.read(routerProvider).go('/login');
    }
  }

  // ── Shared navigation ───────────────────────────────────────────────────
  void goToLogin() => ref.read(routerProvider).go('/login');

  @override
  Widget build(BuildContext context) => widget.builder(this);
}
