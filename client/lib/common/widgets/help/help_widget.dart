import 'package:flutter/material.dart';
import 'package:qfqq/common/widgets/help/help_info.dart';

class HelpWidget extends StatelessWidget {
  final HelpContent content;
  final bool showBackButton;

  const HelpWidget({
    super.key,
    required this.content,
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (showBackButton)
                IconButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(Icons.arrow_back),
                  tooltip: 'Back',
                  visualDensity: VisualDensity.compact,
                ),
              Expanded(
                child: Text(
                  content.title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: colorScheme.primary,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          for (final tip in content.components) tip.build(context),
        ],
      ),
    );
  }
}
