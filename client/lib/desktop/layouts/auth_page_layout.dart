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
          child: Column(
            children: [
              _tilteLine(context, 'Qui', 0),
              _tilteLine(context, 'Fait', 1),
              _tilteLine(context, 'Quoi', 2),
              _tilteLine(context, 'Quand', 3),
            ],
          ),
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

  Widget _tilteLine(BuildContext context, String title, int index) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(width: index * 30),
        Container(
          color: Theme.of(context).colorScheme.primary,
          width: 200,
          child: Center(
            child: Text(
              title,
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ),
        ),
        SizedBox(width: (3 - index) * 30),
      ],
    );
  }
}
