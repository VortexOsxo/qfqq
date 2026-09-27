import 'package:flutter/material.dart';
import 'package:qfqq/common/widgets/help/help_info.dart';
import 'package:qfqq/common/widgets/help/help_selection.dart';
import 'package:qfqq/common/widgets/help/help_widget.dart';

class HelpPage extends StatelessWidget {
  final HelpContent content;

  const HelpPage({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: HelpWidget(content: content, showBackButton: true)),
        const SizedBox(width: 220, child: HelpSelection()),
      ],
    );
  }
}

