import 'package:flutter/material.dart';
import 'package:qfqq/common/models/meeting_agenda.dart';
import 'package:qfqq/generated/l10n.dart';

class StatusUIData {
  final String label;
  final Color color;

  const StatusUIData(this.label, this.color);
}

StatusUIData getMeetingAgendaStatusUI(S loc, MeetingAgendaStatus status) {
  switch (status) {
    case MeetingAgendaStatus.draft:
      return StatusUIData(loc.agendaStatusDraft, Colors.orange);
    case MeetingAgendaStatus.planned:
      return StatusUIData(loc.agendaStatusPlanned, Colors.blue);
    case MeetingAgendaStatus.ongoing:
      return StatusUIData(loc.agendaStatusOngoing, Colors.red);
    case MeetingAgendaStatus.completed:
      return StatusUIData(loc.agendaStatusCompleted, Colors.green);
  }
}
