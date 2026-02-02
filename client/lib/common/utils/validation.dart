import 'package:qfqq/common/models/errors/projects_error.dart';
import 'package:qfqq/common/models/project.dart';
import 'package:qfqq/generated/l10n.dart';

bool stringValidator(String? value) {
  return value != null && value.trim() != "";
}

ProjectErrors validateProject(Project project) {
  var errors = ProjectErrors();

  final loc = S.current;

  errors.titleError =
      stringValidator(project.title) ? null : loc.commonFormsEnterTitle;

  errors.goalsError =
      stringValidator(project.goals) ? null : loc.commonFormsEnterGoals;

  errors.supervisorError =
      stringValidator(project.supervisorId) ? null : loc.commonFormsEnterGoals;

  return errors;
}
