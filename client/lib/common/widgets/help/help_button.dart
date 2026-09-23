import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qfqq/common/widgets/help/help_info.dart';
import 'package:qfqq/common/widgets/help/help_widget.dart';
import 'package:qfqq/generated/l10n.dart';

class HelpButton extends StatelessWidget {
  final HelpContent helpContent;
  final HelpContent detailedHelpContent;

  const HelpButton({
    super.key,
    required this.helpContent,
    required this.detailedHelpContent,
  });

  void _showHelp(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: HelpWidget(content: helpContent),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.push('/help', extra: detailedHelpContent);
              },
              child: Text(S.of(context).helpDialogLearnMore),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(S.of(context).commonClose),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return IconButton(
      onPressed: () => _showHelp(context),
      icon: const Icon(Icons.help_outline_rounded),
      tooltip: helpContent.tooltip,
      style: IconButton.styleFrom(
        foregroundColor: colorScheme.primary,
        overlayColor: colorScheme.primary.withValues(alpha: 0.12),
        padding: const EdgeInsets.all(6),
        shape: const CircleBorder(),
      ),
      visualDensity: VisualDensity.compact,
    );
  }
}
