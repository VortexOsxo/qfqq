import 'package:qfqq/common/models/errors/meeting_agenda_errors.dart';
import 'package:qfqq/common/models/errors/project_errors.dart';
import 'package:qfqq/common/models/meeting_agenda.dart';
import 'package:qfqq/common/models/project.dart';
import 'package:qfqq/generated/l10n.dart';

bool stringValidator(String? value) {
    return value != null && value.trim().isNotEmpty;
}

ProjectErrors validateProject(Project project) {
  var errors = ProjectErrors();

  final loc = S.current;

  errors.titleError =
      stringValidator(project.title) ? null : loc.commonFormsEnterTitle;

  errors.goalsError =
      stringValidator(project.goals) ? null : loc.commonFormsEnterGoals;

  errors.supervisorError =
      stringValidator(project.supervisorId)
          ? null
          : loc.commonFormsEnterSupervisor;

  return errors;
}

MeetingAgendaErrors validateMeetingAgenda(MeetingAgenda agenda) {
  var errors = MeetingAgendaErrors();
  final loc = S.current;

  errors.titleError =
      stringValidator(agenda.title) ? null : loc.commonFormsEnterTitle;

  if (agenda.status == MeetingAgendaStatus.draft) {
    return errors;
  }

  errors.reunionGoalsError =
      stringValidator(agenda.goals) ? null : loc.commonFormsEnterGoals;

  errors.reunionDateError =
      agenda.meetingDate != null ? null : loc.commonFormsEnterMeetingDate;

  errors.reunionLocationError =
      stringValidator(agenda.meetingLocation)
          ? null
          : loc.commonFormsEnterReunionLocation;

  errors.animatorError =
      stringValidator(agenda.animatorId) ? null : loc.commonFormsEnterAnimator;

  errors.participantsError =
      agenda.participantsIds.isNotEmpty
          ? null
          : loc.commonFormsEnterParticipants;

  errors.projectError =
      stringValidator(agenda.projectId) ? null : loc.commonFormsEnterProject;

  return errors;
}
