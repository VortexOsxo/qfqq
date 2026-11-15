import 'package:flutter/material.dart';
import 'package:qfqq/common/widgets/help_page/help_info.dart';

class HelpWidget extends StatelessWidget {
  final HelpContent content;

  const HelpWidget({
    super.key,
    required this.content,
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
          Text(
            content.title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: colorScheme.primary,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),
          for (final tip in content.components) tip.build(context),
        ],
      ),
    );
  }
}
