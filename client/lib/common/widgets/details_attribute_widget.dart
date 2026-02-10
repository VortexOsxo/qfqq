import 'package:flutter/material.dart';

class DetailsAttributeWidget extends StatelessWidget {
  final String label;
  final String value;
  const DetailsAttributeWidget({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 8),
      ],
    );
  }
}
