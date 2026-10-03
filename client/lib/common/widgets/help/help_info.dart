import 'package:flutter/material.dart';

abstract class HelpComponent {
  const HelpComponent();

  Widget build(BuildContext context);
}

class HelpContent {
  final String title;
  final String tooltip;
  final List<HelpComponent> components;

  const HelpContent({
    required this.title,
    required this.tooltip,
    required this.components,
  });
}

class HelpSectionTitle extends HelpComponent {
  final String title;

  const HelpSectionTitle({required this.title}) : super();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}

class HelpParagraph extends HelpComponent {
  final String text;

  const HelpParagraph({required this.text}) : super();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(text),
    );
  }
}

class HelpBulletList extends HelpComponent {
  final String title;
  final List<String> bulletPoints;

  const HelpBulletList({required this.title, required this.bulletPoints}) : super();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: textTheme.titleMedium),
          const SizedBox(height: 8),
          for (final bulletPoint in bulletPoints)
            Padding(
              padding: const EdgeInsets.only(bottom: 4, left: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 7, right: 8),
                    child: Icon(Icons.circle, size: 6),
                  ),
                  Expanded(child: Text(bulletPoint)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
