import 'package:flutter/material.dart';

class TabSelectionWidget extends StatefulWidget {
  final List<String> labels;
  final ValueChanged<int>? onTabSelected;
  final Axis axis;
  final int initialIndex;

  const TabSelectionWidget({
    super.key,
    this.initialIndex = 0,
    required this.labels,
    this.onTabSelected,
    this.axis = Axis.horizontal,
  });

  @override
  State<TabSelectionWidget> createState() => _TabSelectionWidgetState();
}

class _TabSelectionWidgetState extends State<TabSelectionWidget> {
  int selectedTabIndex = -1;

  @override
  void initState() {
    super.initState();
    if (selectedTabIndex == -1) {
      selectedTabIndex = widget.initialIndex;
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> content = [];
    for (var i = 0; i < widget.labels.length - 1; i++) {
      content.add(Expanded(child: _buildTab(context, i)));
      content.add(
        widget.axis == Axis.horizontal
            ? const VerticalDivider(width: 1, thickness: 1, color: Colors.black)
            : const Divider(height: 1, thickness: 1, color: Colors.black),
      );
    }
    content.add(Expanded(child: _buildTab(context, widget.labels.length - 1)));

    final flexWidget =
        widget.axis == Axis.horizontal
            ? Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: content,
            )
            : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: content,
            );

    return Card(
      clipBehavior: Clip.antiAlias,
      child:
          widget.axis == Axis.horizontal
              ? IntrinsicWidth(child: IntrinsicHeight(child: flexWidget))
              : IntrinsicHeight(child: IntrinsicWidth(child: flexWidget)),
    );
  }

  Widget _buildTab(BuildContext context, int index) {
    var isSelected = index == selectedTabIndex;
    var text = widget.labels[index];

    var backgroundColor =
        isSelected
            ? Theme.of(context).primaryColor
            : Theme.of(context).colorScheme.surface;

    var textColor =
        isSelected
            ? Theme.of(context).colorScheme.onPrimary
            : Theme.of(context).colorScheme.onSurface;

    return GestureDetector(
      onTap: () {
        setState(() => selectedTabIndex = index);
        widget.onTabSelected?.call(index);
      },
      child: Container(
        color: backgroundColor,
        child: Padding(
          padding: EdgeInsetsGeometry.all(8),
          child: Center(
            child: Text(
              text,
              style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }
}
