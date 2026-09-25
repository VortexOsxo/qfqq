import 'package:flutter/material.dart';
import 'package:qfqq/common/theme/styles.dart';
import 'package:qfqq/common/utils/get_status_ui.dart';
import 'package:qfqq/common/widgets/icon_status_chip.dart';

class TitleWithStatus extends StatelessWidget {
  final String title;
  final StatusUIData uiData;

  const TitleWithStatus({super.key, required this.title, required this.uiData});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: pageTitleTextStyle(theme),
        ),
        Transform.translate(
          offset: const Offset(0, -10),
          child: IconStatusChip(statusUIData: uiData, iconSize: 20),
        ),
      ],
    );
  }
}
