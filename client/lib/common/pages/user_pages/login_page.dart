import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/services/auth_service.dart';
import 'package:qfqq/common/providers/router_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:qfqq/common/services/forgotten_password_service.dart';
import 'package:qfqq/common/theme/styles.dart';
import 'package:qfqq/common/widgets/reusables/adaptive_layout.dart';
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
    return AdaptiveLayout(
      mobile: (_) => _MobileLayout(formKey: _formKey, onSubmit: _submit, error: error,
        onEmailSaved: (v) => email = v ?? '',
        onPasswordSaved: (v) => password = v ?? '',
      ),
      desktop: (_) => _DesktopLayout(formKey: _formKey, onSubmit: _submit, error: error,
        onEmailSaved: (v) => email = v ?? '',
        onPasswordSaved: (v) => password = v ?? '',
      ),
    );
  }
}

class _LoginForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final VoidCallback onSubmit;
  final String error;
  final ValueSetter<String?> onEmailSaved;
  final ValueSetter<String?> onPasswordSaved;

  const _LoginForm({
    required this.formKey,
    required this.onSubmit,
    required this.error,
    required this.onEmailSaved,
    required this.onPasswordSaved,
  });

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);
    return Form(
      key: formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            decoration: InputDecoration(labelText: loc.attributeEmail),
            onSaved: onEmailSaved,
          ),
          const SizedBox(height: 8),
          TextFormField(
            decoration: InputDecoration(labelText: loc.attributePassword),
            obscureText: true,
            onSaved: onPasswordSaved,
          ),
          const SizedBox(height: 16),
          if (error.isNotEmpty)
            Text(error, style: const TextStyle(color: Colors.red)),
          ElevatedButton(
            style: squareButtonStyle(context),
            onPressed: onSubmit,
            child: Text(loc.loginPageButtonLogin),
          ),
          const SizedBox(height: 32),
          Consumer(builder: (context, ref, _) => Column(
            children: [
              TextButton(
                onPressed: () => context.go('/signup'),
                child: Text(loc.loginPageLinkSignup),
              ),
              TextButton(
                onPressed: () {
                  ref.read(forgottenPasswordStateProvider.notifier).reset();
                  context.go('/forgotten-password');
                },
                child: Text(loc.loginPageForgottenPasswordLink),
              ),
            ],
          )),
        ],
      ),
    );
  }
}

class _MobileLayout extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final VoidCallback onSubmit;
  final String error;
  final ValueSetter<String?> onEmailSaved;
  final ValueSetter<String?> onPasswordSaved;

  const _MobileLayout({
    required this.formKey,
    required this.onSubmit,
    required this.error,
    required this.onEmailSaved,
    required this.onPasswordSaved,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: _LoginForm(
        formKey: formKey,
        onSubmit: onSubmit,
        error: error,
        onEmailSaved: onEmailSaved,
        onPasswordSaved: onPasswordSaved,
      ),
    );
  }
}

class _DesktopLayout extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final VoidCallback onSubmit;
  final String error;
  final ValueSetter<String?> onEmailSaved;
  final ValueSetter<String?> onPasswordSaved;

  const _DesktopLayout({
    required this.formKey,
    required this.onSubmit,
    required this.error,
    required this.onEmailSaved,
    required this.onPasswordSaved,
  });

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
                child: _LoginForm(
                  formKey: formKey,
                  onSubmit: onSubmit,
                  error: error,
                  onEmailSaved: onEmailSaved,
                  onPasswordSaved: onPasswordSaved,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
