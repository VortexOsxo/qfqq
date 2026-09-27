import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qfqq/common/utils/help_util.dart';
import 'package:qfqq/common/widgets/hover_text_button.dart';
import 'package:qfqq/generated/l10n.dart';

class HelpSelection extends StatelessWidget {
  const HelpSelection({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final railColor =
        Color.lerp(Colors.grey.shade600, colorScheme.primaryContainer, 0.03)!;
    final children = [
      for (final factory in helpLinksFactories)
        _HelpLink(content: factory(loc)),
    ];

    return Container(
      color: railColor,
      height: double.infinity,
      padding: EdgeInsets.all(8),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }
}

class _HelpLink extends StatelessWidget {
  final HelpLink content;

  const _HelpLink({required this.content});

  @override
  Widget build(BuildContext context) {
    return HoverTextButton(
      text: content.getTitle(),
      isActive: false,
      color: Colors.white,
      fontSize: 14,
      fontWeight: FontWeight.normal,
      activeFontWeight: FontWeight.normal,
      hoverFontWeight: FontWeight.bold,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      iconSize: 16,
      iconWidth: 14,
      spacing: 2,
      onTap: () {
        Navigator.of(context).pop();
        context.push('/help', extra: content.getContent());
      },
    );
  }
}
