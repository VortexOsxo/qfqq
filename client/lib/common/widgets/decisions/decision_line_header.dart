import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qfqq/common/models/decision.dart';

class DecisionLineHeader extends StatelessWidget {
  final Decision decision;

  const DecisionLineHeader({super.key, required this.decision});

  @override
  Widget build(BuildContext context) {
    final dueDateText =
        decision.dueDate != null
            ? DateFormat.yMMMd().format(decision.dueDate!)
            : 'No due date';

    final statusText = getDecisionStatusName(decision.status);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(decision.description, style: TextStyle(fontSize: 16)),
          Text(statusText, style: TextStyle(fontSize: 14, color: Colors.grey)),
          Text(dueDateText, style: TextStyle(fontSize: 14, color: Colors.grey)),
        ],
      ),
    );
  }
}
