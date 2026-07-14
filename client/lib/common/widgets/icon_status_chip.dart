import 'package:flutter/material.dart';
import 'package:qfqq/common/utils/get_status_ui.dart';

class IconStatusChip extends StatelessWidget {
  final StatusUIData statusUIData;
  final double? iconSize;

  const IconStatusChip({
    super.key,
    required this.statusUIData,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(
      statusUIData.icon,
      color: statusUIData.color,
      size: iconSize ?? 16,
    );
  }
}
