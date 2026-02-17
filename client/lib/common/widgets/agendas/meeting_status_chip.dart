import 'package:flutter/material.dart';
import 'package:qfqq/common/models/meeting_agenda.dart';
import 'package:qfqq/common/utils/get_status_ui.dart';
import 'package:qfqq/generated/l10n.dart';

class MeetingStatusChip extends StatelessWidget {
  final MeetingAgendaStatus status;

  const MeetingStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    var statusUIData = getMeetingAgendaStatusUI(S.of(context), status);

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: 80,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: statusUIData.color.withAlpha(26),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: statusUIData.color),
        ),
        child: Center(
          child: Text(
            statusUIData.label,
            style: TextStyle(
              color: statusUIData.color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
