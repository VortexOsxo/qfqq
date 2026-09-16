import 'package:flutter/material.dart';

class AuthPageLayout extends StatelessWidget {
  final Widget child;

  const AuthPageLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Image.asset('assets/background.png'),
        ),

        Expanded(
          flex: 2,
          child: Center(
            child: Padding(padding: const EdgeInsets.all(32), child: child),
          ),
        ),

        Expanded(flex: 1, child: Container()),
      ],
    );
  }
}
