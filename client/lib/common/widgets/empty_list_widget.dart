import 'package:flutter/material.dart';

class EmptyListWidget extends StatelessWidget {
  final String text;

  const EmptyListWidget({super.key, required this.text});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.list_alt, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            text,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
