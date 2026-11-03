import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qfqq/common/models/decision.dart';
import 'package:qfqq/common/utils/fromatting.dart';
import 'package:qfqq/common/utils/get_status_ui.dart';
import 'package:qfqq/common/utils/platform.dart';
import 'package:qfqq/common/widgets/navigation/navigation_arrow_icon.dart';
import 'package:qfqq/generated/l10n.dart';

class DecisionLineHeader extends StatelessWidget {
  final Decision decision;

  const DecisionLineHeader({super.key, required this.decision});

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);
    final dueDate = decision.dueDate?.toLocal();

    final today = DateUtils.dateOnly(DateTime.now());
    final dueDay = DateUtils.dateOnly(dueDate!);

    String dueDateText;
    Color dueDateColor;
    FontWeight weight;

    if (dueDay.isBefore(today)) {
      dueDateText = loc.decisionOverdue(formatDateDay(context, dueDate));
      dueDateColor = Colors.red;
      weight = FontWeight.w600;
    } else if (dueDay == today) {
      dueDateText = loc.decisionDueToday;
      dueDateColor = Colors.blueGrey;
      weight = FontWeight.w500;
    } else {
      dueDateText = formatDateDay(context, dueDate);
      dueDateColor = Colors.grey;
      weight = FontWeight.normal;
    }

    final statusText = getDecisionStatusUI(loc, decision.status).label;
    Future<Object?> navigate() => context.push('/decisions/${decision.id}');
    final viewButton = NavigationArrowIcon(
      tooltip: loc.commonView,
      onPressed: navigate,
    );

    final statusAndDeadline = Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '$statusText · ',
            style: const TextStyle(color: Colors.grey),
          ),
          TextSpan(
            text: dueDateText,
            style: TextStyle(color: dueDateColor, fontWeight: weight),
          ),
        ],
      ),
      style: const TextStyle(fontSize: 14),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );

    return InkWell(
      onTap: navigate,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final title = Text(
              decision.description,
              style: TextStyle(fontSize: 16),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            );
            if (constraints.maxWidth < 600) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  title,
                  Row(
                    children: [
                      Expanded(child: statusAndDeadline),
                      if (platformType != PlatformType.desktop) viewButton,
                    ],
                  ),
                ],
              );
            }

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: title),
                SizedBox(width: 12),
                statusAndDeadline,
                const SizedBox(width: 8),
                if (platformType != PlatformType.desktop) viewButton,
              ],
            );
          },
        ),
      ),
    );
  }
}
