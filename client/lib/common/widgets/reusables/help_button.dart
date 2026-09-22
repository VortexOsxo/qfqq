import 'package:flutter/material.dart';
import 'package:qfqq/common/models/help_info.dart';
import 'package:qfqq/generated/l10n.dart';

class HelpButton extends StatelessWidget {
  final HelpContent help;

  const HelpButton({super.key, required this.help});

  void _showHelp(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(help.title),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [for (final tip in help.tips) _HelpSection(info: tip)],
            ),
          ),
          actions: [
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
      tooltip: help.tooltip,
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

class _HelpSection extends StatelessWidget {
  final HelpInfo info;

  const _HelpSection({required this.info});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(info.title, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 4),
          Text(info.description),
        ],
      ),
    );
  }
}
