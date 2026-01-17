import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:qfqq/common/models/decision.dart';
import 'package:qfqq/generated/l10n.dart';

class DecisionLineHeader extends StatelessWidget {
  final Decision decision;

  const DecisionLineHeader({super.key, required this.decision});

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);
    final dueDateText =
        decision.dueDate != null
            ? DateFormat.yMMMd().format(decision.dueDate!)
            : loc.commonNoDueDate;

    final statusText = getDecisionStatusName(decision.status);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(decision.description, style: TextStyle(fontSize: 16)),
          Spacer(),
          Text(statusText, style: TextStyle(fontSize: 14, color: Colors.grey)),
          SizedBox(width: 8),
          Text(dueDateText, style: TextStyle(fontSize: 14, color: Colors.grey)),
          TextButton(
            child: Text(loc.commonView),
            onPressed: () => context.go('/decisions/${decision.id}'),
          ),
        ],
      ),
    );
  }
}
