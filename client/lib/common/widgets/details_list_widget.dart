import 'package:flutter/material.dart';
import 'package:qfqq/generated/l10n.dart';

class DetailsListWidget extends StatelessWidget {
  final String label;
  final String emptyLabel;
  final List<String> values;

  const DetailsListWidget({
    super.key,
    required this.label,
    required this.emptyLabel,
    required this.values,
  });

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);
    if (values.isEmpty) {
      return Text(loc.attributeNoThemes);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children:
              values
                  .map(
                    (value) =>
                        Text('• $value', style: const TextStyle(fontSize: 16)),
                  )
                  .toList(),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
