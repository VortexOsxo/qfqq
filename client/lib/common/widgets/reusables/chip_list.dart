import 'package:flutter/material.dart';

class ChipList<T> extends StatelessWidget {
  final List<T> items;
  final String Function(T) displayString;
  final void Function(T) onDelete;

  const ChipList({
    super.key,
    required this.items,
    required this.displayString,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);

    var itemsLabel =
        items
            .map(
              (item) => Chip(
                label: Text(displayString(item)),
                onDeleted: () => onDelete(item),
                backgroundColor: theme.colorScheme.primaryContainer.withValues(
                  alpha: .3,
                ),
                deleteIconColor: theme.colorScheme.onSurfaceVariant,
                labelStyle: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            )
            .toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Wrap(spacing: 8.0, runSpacing: 8.0, children: itemsLabel),
    );
  }
}
