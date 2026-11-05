import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qfqq/common/models/decision.dart';
import 'package:qfqq/common/utils/fromatting.dart';
import 'package:qfqq/common/utils/get_status_ui.dart';
import 'package:qfqq/common/widgets/home_page/home_shortcut_header_widget.dart';
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

    final statusText = getDecisionStatusUI(loc, decision.status).label;

    String dateText;
    HeaderStyle style;
    if (dueDay.isBefore(today)) {
      style = HeaderStyle.urgent;
      dateText = loc.decisionOverdue(formatDateDay(context, dueDate));
    } else if (dueDay == today) {
      style = HeaderStyle.today;
      dateText = loc.decisionDueToday;
    } else {
      style = HeaderStyle.normal;
      dateText = formatDateDay(context, dueDate);
    }

    return HomeShortcutHeaderWidget(
      description: decision.description,
      style: style,
      statusText: statusText,
      dateText: dateText,
      navigate: () => context.push('/decisions/${decision.id}'),
    );
  }
}
