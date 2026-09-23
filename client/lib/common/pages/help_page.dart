import 'package:flutter/material.dart';
import 'package:qfqq/common/widgets/help/help_info.dart';
import 'package:qfqq/common/widgets/help/help_widget.dart';

class HelpPage extends StatelessWidget {
  final HelpContent content;

  const HelpPage({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return HelpWidget(content: content, showBackButton: true);
  }
}

