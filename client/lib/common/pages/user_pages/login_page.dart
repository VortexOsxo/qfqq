import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/services/auth_service.dart';
import 'package:qfqq/common/providers/router_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:qfqq/common/widgets/common_app_bar.dart';
import 'package:qfqq/generated/l10n.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  String error = '';

  void _submit() async {
    setState(() => error = '');
    _formKey.currentState?.save();

    final authService = ref.read(authStateProvider.notifier);
    final errors = await authService.login(email, password);
    String? e = errors.getFirstError();

    if (e != null) {
      setState(() => error = e);
    } else {
      ref.read(routerProvider).go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);
    
    return Scaffold(
      appBar: CommonAppBar(title: loc.loginPageTitle, showHomeButton: false),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: loc.loginPageLabelEmail),
                onSaved: (val) => email = val ?? '',
              ),
              TextFormField(
                decoration: InputDecoration(labelText: loc.loginPageLabelPassword),
                obscureText: true,
                onSaved: (val) => password = val ?? '',
              ),
              const SizedBox(height: 16),
              if (error.isNotEmpty)
                Text(error, style: const TextStyle(color: Colors.red)),
              ElevatedButton(
                onPressed: _submit,
                child: Text(loc.loginPageButtonLogin),
              ),
              TextButton(
                onPressed: () => context.go('/signup'),
                child: Text(loc.loginPageLinkSignup),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
