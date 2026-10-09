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
    final children = [
      for (final factory in helpLinksFactories)
        _HelpLink(content: factory(loc)),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(height: 8,),
        ...children
      ],
    );
  }
}

class _HelpLink extends StatelessWidget {
  final HelpLink content;

  const _HelpLink({required this.content});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return HoverTextButton(
      text: content.getTitle(),
      isActive: false,
      color: colorScheme.primary,
      fontSize: 14,
      fontWeight: FontWeight.normal,
      activeFontWeight: FontWeight.normal,
      hoverFontWeight: FontWeight.bold,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      iconSize: 16,
      iconWidth: 14,
      spacing: 2,
      onTap: () {
        final router = GoRouter.of(context);

        Navigator.of(context).pop();
        router.push('/help', extra: content.getContent());
      },
    );
  }
}
