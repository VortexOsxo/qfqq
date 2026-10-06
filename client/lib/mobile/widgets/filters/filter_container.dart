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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [_buildToggle(context), if (_isExpanded) widget.child],
    );
  }

  Widget _buildToggle(BuildContext context) {
    final theme = Theme.of(context);
    final title = widget.title ?? S.of(context).commonFilters;
    final primaryColor = theme.colorScheme.primary;

    return GestureDetector(
      child: Row(
        children: [
          Icon(
            _isExpanded ? Icons.arrow_drop_down : Icons.arrow_right,
            color: theme.colorScheme.primary,
          ),
          Text(
            title,
            style: TextStyle(color: primaryColor, fontWeight: FontWeight.w600),
          ),
        ],
      ),
      onTap: () => setState(() => _isExpanded = !_isExpanded),
    );
  }
}
