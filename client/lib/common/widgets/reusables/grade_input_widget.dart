import 'package:flutter/material.dart';

class GradeInputWidget extends StatefulWidget {
  final String label;
  final int? initialValue;
  final ValueChanged<int> onChanged;
  final String? errorText;

  const GradeInputWidget({
    super.key,
    required this.label,
    required this.onChanged,
    this.initialValue,
    this.errorText,
  });

  @override
  State<GradeInputWidget> createState() => _GradeInputWidgetState();
}

class _GradeInputWidgetState extends State<GradeInputWidget> {
  late int selectedValue;

  @override
  void initState() {
    super.initState();
    selectedValue = widget.initialValue ?? -1;
  }

  void _onGradeSelected(int value) {
    setState(() => selectedValue = value);
    widget.onChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 5,
          runSpacing: 5,
          children: List.generate(5, (index) {
            final value = index + 1;
            final selected = selectedValue == value;

            return ChoiceChip(
              label: Text(value.toString()),
              selected: selected,
              onSelected: (_) => _onGradeSelected(value),
              showCheckmark: false,
              selectedColor: theme.colorScheme.primary,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              labelStyle: TextStyle(
                color: selected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            );
          }),
        ),
        if (widget.errorText != null) ...[
          const SizedBox(height: 8),
          Text(
            widget.errorText!,
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error),
          ),
        ],
      ],
    );
  }
}
