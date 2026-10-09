import 'package:flutter/material.dart';
import 'package:qfqq/generated/l10n.dart';

class FilterContainer extends StatefulWidget {
  final String? title;
  final Widget child;

  const FilterContainer({super.key, this.title, required this.child});

  @override
  State<FilterContainer> createState() => _FilterContainerState();
}

class _FilterContainerState extends State<FilterContainer> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final title = widget.title ?? S.of(context).commonFilters;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        if (_isExpanded)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: primaryColor, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: widget.child,
              ),
            ),
          )
        else
          SizedBox(width: double.infinity, height: 14),
        if (!_isExpanded)
          Positioned(
            top: 12,
            left: 0,
            right: 0,
            child: Container(height: 2, color: primaryColor),
          ),
        Positioned(
          top: 0,
          left: 12,
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: _buildToggleLabel(
              title,
              primaryColor,
              expanded: _isExpanded,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildToggleLabel(
    String title,
    Color color, {
    required bool expanded,
  }) {
    return Semantics(
      button: true,
      expanded: expanded,
      label: title,
      child: InkWell(
        borderRadius: BorderRadius.circular(4),
        onTap: () => setState(() => _isExpanded = !_isExpanded),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                expanded ? Icons.arrow_drop_down : Icons.arrow_right,
                color: color,
                size: 20,
              ),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.labelMedium!.copyWith(color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
