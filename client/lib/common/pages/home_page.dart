import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qfqq/generated/l10n.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(S.of(context).homePageTitle)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => context.go('/agenda'),
              child: Text(S.of(context).homePageCreateAgenda),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => context.go('/agendas'),
              child: Text(S.of(context).homePageUpdateAgenda),
            ),
          ],
        ),
      ),
    );
  }
}
