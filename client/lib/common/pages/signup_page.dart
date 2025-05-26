import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/providers/router_provider.dart';
import 'package:qfqq/common/services/auth_service.dart';
import 'package:go_router/go_router.dart';
import 'package:qfqq/generated/l10n.dart';

class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({super.key});

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  final _signupFormKey = GlobalKey<FormState>();

  String signupUsername = '';
  String signupPassword = '';
  String signupEmail = '';
  String signupError = '';

  void _submitSignup() async {
    setState(() => signupError = '');
    if (_signupFormKey.currentState?.validate() ?? false) {
      _signupFormKey.currentState?.save();
      final authService = ref.read(authStateProvider.notifier);
      try {
        final accountError = await authService.signup(
          signupUsername,
          signupEmail,
          signupPassword,
        );
        
        if (accountError.usernameError != null) {
          setState(() => signupError = accountError.usernameError!);
        }
        else if (accountError.emailError != null) {
          setState(() => signupError = accountError.emailError!);
        }
        else if (accountError.passwordError != null) {
          setState(() => signupError = accountError.passwordError!);
        }
        else {
          ref.read(routerProvider).go('/');
        }
      } catch (e) {
        setState(() => signupError = e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(loc.signupPageTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _signupFormKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: loc.signupPageLabelEmail),
                onSaved: (val) => signupEmail = val ?? '',
              ),
              TextFormField(
                decoration: InputDecoration(labelText: loc.signupPageLabelUsername),
                onSaved: (val) => signupUsername = val ?? '',
              ),
              TextFormField(
                decoration: InputDecoration(labelText: loc.signupPageLabelPassword),
                obscureText: true,
                onSaved: (val) => signupPassword = val ?? '',
              ),
              const SizedBox(height: 16),
              if (signupError.isNotEmpty)
                Text(signupError, style: const TextStyle(color: Colors.red)),
              ElevatedButton(
                onPressed: _submitSignup,
                child: Text(loc.signupPageButtonSignup),
              ),
              TextButton(
                onPressed: () => context.go('/login'),
                child: Text(loc.signupPageLinkLogin),
              ),
            ],
          ),
        ),
      ),
    );
  }
}