import 'package:flutter/material.dart';
import 'package:qfqq/common/models/meeting_agenda.dart';
import 'package:qfqq/generated/l10n.dart';

class MeetingStatusChip extends StatelessWidget {
  final MeetingAgendaStatus status;

  const MeetingStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    switch (status) {
      case MeetingAgendaStatus.draft:
        color = Colors.orange;
        label = S.of(context).agendaStatusDraft;
        break;
      case MeetingAgendaStatus.planned:
        color = Colors.blue;
        label = S.of(context).agendaStatusPlanned;
        break;
      case MeetingAgendaStatus.completed:
        color = Colors.green;
        label = S.of(context).agendaStatusCompleted;
        break;
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: 80,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withAlpha(26),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
