import 'package:flutter/material.dart';
import 'package:qfqq/common/widgets/scaffolds/auth_page_scaffold.dart';
import 'package:qfqq/common/widgets/reusables/return_login_widget.dart';
import 'package:qfqq/generated/l10n.dart';

class SubscribePage extends StatelessWidget {
  const SubscribePage({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);
    final theme = Theme.of(context);

    return authPageScaffold(
      context,
      Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              loc.subscribePageTrialEnded,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Text(loc.subscribePageContactPrompt, textAlign: TextAlign.center),
            const SizedBox(height: 4),
            SelectableText(
              'qfqq.communication@gmail.com',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            const ReturnLoginWidget(),
          ],
        ),
      ),
      title: loc.subscribePageTitle,
    );
  }
}
