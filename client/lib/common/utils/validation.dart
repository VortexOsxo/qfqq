import 'package:qfqq/common/models/errors/meeting_agenda_errors.dart';
import 'package:qfqq/common/models/errors/project_errors.dart';
import 'package:qfqq/common/models/meeting_agenda.dart';
import 'package:qfqq/common/models/project.dart';
import 'package:qfqq/generated/l10n.dart';

bool stringValidator(String? value) {
  return value != null && value.trim().isNotEmpty;
}

bool idValidator(int? id) {
  return id != null && id > 0;
}

ProjectErrors validateProject(Project project) {
  var errors = ProjectErrors();

  final loc = S.current;

  errors.titleError =
      stringValidator(project.title) ? null : loc.commonFormsEnterTitle;

  errors.goalsError =
      stringValidator(project.goals) ? null : loc.commonFormsEnterGoals;

  errors.supervisorError =
      idValidator(project.supervisorId) ? null : loc.commonFormsEnterSupervisor;

  return errors;
}

MeetingAgendaErrors validateMeetingAgenda(
  MeetingAgenda agenda, {
  MeetingAgendaStatus? wantedStatus,
}) {
  var errors = MeetingAgendaErrors();
  final loc = S.current;

  errors.titleError =
      stringValidator(agenda.title) ? null : loc.commonFormsEnterTitle;

  wantedStatus ??= agenda.status;
  if (wantedStatus == MeetingAgendaStatus.draft) {
    return errors;
  }

  errors.goalsError =
      stringValidator(agenda.goals) ? null : loc.commonFormsEnterGoals;

  errors.meetingDateError =
      agenda.meetingDate != null ? null : loc.commonFormsEnterMeetingDate;

  errors.meetingLocationError =
      stringValidator(agenda.meetingLocation)
          ? null
          : loc.commonFormsEnterReunionLocation;

  errors.animatorError =
      idValidator(agenda.animatorId) ? null : loc.commonFormsEnterAnimator;

  errors.participantsError =
      agenda.participantsIds.isNotEmpty
          ? null
          : loc.commonFormsEnterParticipants;

  errors.projectError =
      idValidator(agenda.projectId) ? null : loc.commonFormsEnterProject;

  return errors;
}
