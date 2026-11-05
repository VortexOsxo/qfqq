import 'package:flutter/material.dart';
import 'package:qfqq/common/utils/platform.dart';
import 'package:qfqq/common/widgets/navigation/navigation_arrow_icon.dart';
import 'package:qfqq/generated/l10n.dart';

enum HeaderStyle { normal, today, urgent }

class HomeShortcutHeaderWidget extends StatelessWidget {
  final String description;
  final HeaderStyle style;
  final String statusText;
  final String dateText;
  final void Function() navigate;

  const HomeShortcutHeaderWidget({
    super.key,
    required this.description,
    required this.style,
    required this.statusText,
    required this.dateText,
    required this.navigate,
  });

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);

    Color dueDateColor;
    FontWeight weight;

    if (style == HeaderStyle.urgent) {
      dueDateColor = Colors.red;
      weight = FontWeight.w600;
    } else if (style == HeaderStyle.today) {
      dueDateColor = Colors.blueGrey;
      weight = FontWeight.w500;
    } else {
      dueDateColor = Colors.grey;
      weight = FontWeight.normal;
    }

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
            text: dateText,
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
              description,
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
