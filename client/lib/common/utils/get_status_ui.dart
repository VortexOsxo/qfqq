import 'package:flutter/material.dart';
import 'package:qfqq/common/models/decision.dart';
import 'package:qfqq/common/models/meeting_agenda.dart';
import 'package:qfqq/generated/l10n.dart';

class StatusUIData {
  final String label;
  final Color color;
  final IconData icon;

  const StatusUIData(this.label, this.color, this.icon);
}

StatusUIData getMeetingAgendaStatusUI(S loc, MeetingAgendaStatus status) {
  switch (status) {
    case MeetingAgendaStatus.draft:
      return StatusUIData(loc.agendaStatusDraft, Colors.orange, Icons.edit);
    case MeetingAgendaStatus.planned:
      return StatusUIData(loc.agendaStatusPlanned, Colors.blue, Icons.calendar_today);
    case MeetingAgendaStatus.ongoing:
      return StatusUIData(loc.agendaStatusOngoing, Colors.red, Icons.hourglass_bottom);
    case MeetingAgendaStatus.canceled:
      return StatusUIData(loc.agendaStatusCanceled, Colors.grey, Icons.cancel);
    case MeetingAgendaStatus.completed:
      return StatusUIData(loc.agendaStatusCompleted, Colors.green, Icons.check_circle);
  }
}

StatusUIData getDecisionStatusUI(S loc, DecisionStatus status) {
  switch (status) {
    case DecisionStatus.inProgress:
      return StatusUIData(loc.decisionStatusInProgress, Colors.blue, Icons.hourglass_bottom);
    case DecisionStatus.cancelled:
      return StatusUIData(loc.decisionStatusCancelled, Colors.red, Icons.cancel);
    case DecisionStatus.completed:
      return StatusUIData(loc.decisionStatusCompleted, Colors.green, Icons.check_circle);
  }
}
