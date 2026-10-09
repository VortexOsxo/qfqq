import 'package:flutter/material.dart';
import 'package:qfqq/common/utils/platform.dart';
import 'package:qfqq/common/widgets/help/help_info.dart';
import 'package:qfqq/common/widgets/help/help_selection.dart';
import 'package:qfqq/common/widgets/help/help_widget.dart';

class HelpPage extends StatelessWidget {
  final HelpContent content;

  const HelpPage({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    if (platformType == PlatformType.mobile) {
      return HelpWidget(content: content, showBackButton: true);
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: HelpWidget(content: content, showBackButton: true)),
        const SizedBox(width: 16),
        SizedBox(
          width: 220,
          child: Card(
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Theme.of(context).primaryColor, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(child: HelpSelection()),
          ),
        ),
      ],
    );
  }
}
