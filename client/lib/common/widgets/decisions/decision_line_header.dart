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
    final dueDateText = formatDateDayIfPresent(context, decision.dueDate);

    final statusText = getDecisionStatusUI(loc, decision.status).label;
    Future<Object?> navigate() => context.push('/decisions/${decision.id}');
    final viewButton = NavigationArrowIcon(tooltip: loc.commonView, onPressed: navigate);

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
                      Expanded(
                        child: Text(
                          '$statusText · $dueDateText',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ),
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
                Text(
                  '$statusText · $dueDateText',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
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
