import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/services/auth_service.dart';
import 'package:qfqq/common/providers/router_provider.dart';
import 'package:qfqq/common/services/forgotten_password_service.dart';

class LoginPageViewModel extends ConsumerStatefulWidget {
  final Widget Function(LoginPageViewModelState vm) builder;

  const LoginPageViewModel({super.key, required this.builder});

  @override
  ConsumerState<LoginPageViewModel> createState() => LoginPageViewModelState();
}

class LoginPageViewModelState extends ConsumerState<LoginPageViewModel> {
  final formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  String error = '';
  bool stay = false;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback(_checkRefresh);
    super.initState();
  }

  void submit() async {
    setState(() => error = '');
    formKey.currentState?.save();

    final authService = ref.read(authStateProvider.notifier);
    final errors = await authService.login(email, password, stay);
    String? e = errors.getFirstError();

    if (e != null) {
      setState(() => error = e);
    } else {
      final authState = ref.read(authStateProvider);
      if (authState.hasOrg) {
        ref.read(routerProvider).go('/');
      } else {
        ref.read(routerProvider).go('/organizations/links');
      }
    }
  }

  void goToSignup() => ref.read(routerProvider).go('/signup');
  void goToCreateOrganization() => ref.read(routerProvider).go('/organizations/creation');
  void goToForgottenPassword() {
    ref.read(forgottenPasswordStateProvider.notifier).reset();
    ref.read(routerProvider).go('/forgotten-password');
  }

  void savePassword(String? val) => password = val ?? '';
  void saveEmail(String? val) => email = val ?? '';
  void saveStay(bool? val) => setState(() => stay = val ?? false);

  void _checkRefresh(_) async {
    final service = ref.read(authStateProvider.notifier);

    final result = await service.refresh();
    if (!result || !mounted) {
      return;
    }

    final authState = ref.read(authStateProvider);
    if (authState.hasOrg) {
      ref.read(routerProvider).go('/');
    } else {
      ref.read(routerProvider).go('/organizations/links');
    }
  }

  @override
  Widget build(BuildContext context) => widget.builder(this);
}
