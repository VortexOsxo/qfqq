import 'package:qfqq/generated/l10n.dart';

class DecisionErrors {
  String? descriptionError;
  String? responsibleError;
  String? dueDateError;

  DecisionErrors({
    this.descriptionError,
    this.responsibleError,
    this.dueDateError,
  });

  bool hasAny() {
    return descriptionError != null ||
        responsibleError != null ||
        dueDateError != null;
  }

  DecisionErrors.fromJson(dynamic json) {
    if (json == null || json is! Map) return;

    var loc = S.current;
    if (json.containsKey('description')) {
      descriptionError = loc.commonFormsEnterDescription;
    }
    if (json.containsKey('responsibleId')) {
      responsibleError = loc.commonFormsEnterResponsible;
    }
    if (json.containsKey('dueDate')) {
      dueDateError = loc.commonFormsEnterDueDate;
    }
  }
}
