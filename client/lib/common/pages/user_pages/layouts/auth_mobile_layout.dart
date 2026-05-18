import 'package:flutter/material.dart';

class AuthMobileLayout extends StatelessWidget {
  final Widget child;

  const AuthMobileLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: child,
    );
  }
}
