import 'package:flutter/material.dart';
import 'package:qfqq/common/utils/platform.dart';
import 'package:qfqq/common/widgets/help/help_info.dart';
import 'package:qfqq/common/widgets/help/help_selection.dart';
import 'package:qfqq/common/widgets/help/help_widget.dart';
import 'package:qfqq/generated/l10n.dart';

class HelpPage extends StatefulWidget {
  final HelpContent content;

  const HelpPage({super.key, required this.content});

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  bool _showHelpSelection = false;

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);
    final canShowHelpSelection = platformType != PlatformType.mobile;

    if (!canShowHelpSelection) {
      return HelpWidget(
        content: widget.content,
        showBackButton: true,
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: HelpWidget(
            content: widget.content,
            showBackButton: true,
            titleAction: IconButton(
              tooltip:
                  _showHelpSelection
                      ? loc.helpSelectionHide
                      : loc.helpSelectionShow,
              onPressed:
                  () =>
                      setState(() => _showHelpSelection = !_showHelpSelection),
              icon: Icon(_showHelpSelection ? Icons.menu_open : Icons.menu),
            ),
          ),
        ),
        if (_showHelpSelection)
          const SizedBox(width: 220, child: HelpSelection()),
      ],
    );
  }
}
