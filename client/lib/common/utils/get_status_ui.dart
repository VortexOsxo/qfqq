import 'package:flutter/material.dart';
import 'package:qfqq/common/models/decision.dart';
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

StatusUIData getDecisionStatusUI(S loc, DecisionStatus status) {
  switch (status) {
    case DecisionStatus.inProgress:
      return StatusUIData(loc.decisionStatusInProgress, Colors.blue);
    case DecisionStatus.cancelled:
      return StatusUIData(loc.decisionStatusCancelled, Colors.red);
    case DecisionStatus.completed:
      return StatusUIData(loc.decisionStatusCompleted, Colors.green);
  }
}
