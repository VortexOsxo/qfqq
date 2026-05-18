import 'package:flutter/material.dart';

class AuthDesktopLayout extends StatelessWidget {
  final Widget child;

  const AuthDesktopLayout({super.key, required this.child});

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
                child: SingleChildScrollView(child: child),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
