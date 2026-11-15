import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qfqq/common/utils/help_util.dart';
import 'package:qfqq/common/widgets/hover_text_button.dart';
import 'package:qfqq/generated/l10n.dart';

class HelpSelection extends StatelessWidget {
  final Type selected;
  const HelpSelection({super.key, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        for (final section in helpSections)
          _HelpSection(section: section, selected: selected),
      ],
    );
  }
}

class _HelpSection extends StatelessWidget {
  final HelpSection section;
  final Type selected;

  const _HelpSection({required this.section, required this.selected});

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Text(
            section.getName(loc),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
        ),
        for (final link in section.getSections(loc))
          _HelpLink(content: link, isSelected: link.id == selected),
      ],
    );
  }
}

class _HelpLink extends StatelessWidget {
  final HelpLink content;
  final bool isSelected;

  const _HelpLink({required this.content, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return HoverTextButton(
      text: content.getTitle(),
      isActive: isSelected,
      color: colorScheme.primary,
      fontSize: 14,
      fontWeight: FontWeight.normal,
      activeFontWeight: FontWeight.normal,
      hoverFontWeight: FontWeight.bold,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      iconSize: 20,
      iconWidth: 20,
      spacing: 2,
      onTap: () {
        final router = GoRouter.of(context);

        Navigator.of(context).pop();
        router.push('/help', extra: content.getContent());
      },
    );
  }
}
