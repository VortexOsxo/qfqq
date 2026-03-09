import 'package:flutter/material.dart';
import 'package:qfqq/common/utils/get_status_ui.dart';

class StatusChip extends StatelessWidget {
  final StatusUIData statusUIData;

  const StatusChip({super.key, required this.statusUIData});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: statusUIData.color.withAlpha(26),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: statusUIData.color),
        ),
        child: Text(
          statusUIData.label,
          style: TextStyle(
            color: statusUIData.color,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
