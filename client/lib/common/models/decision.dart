import 'package:qfqq/common/utils/is_id_valid.dart';
import 'package:qfqq/generated/l10n.dart';

enum DecisionStatus {
  inProgress,
  cancelled,
  pending,
  completed,
  taskDescription,
  approved,
  toBeValidated,
}

getDecisionStatusName(DecisionStatus status) {
  switch (status) {
    case DecisionStatus.inProgress:
      return S.current.decisionStatusInProgress;
    case DecisionStatus.cancelled:
      return S.current.decisionStatusCancelled;
    case DecisionStatus.pending:
      return S.current.decisionStatusPending;
    case DecisionStatus.completed:
      return S.current.decisionStatusCompleted;
    case DecisionStatus.taskDescription:
      return S.current.decisionStatusTaskDescription;
    case DecisionStatus.approved:
      return S.current.decisionStatusApproved;
    case DecisionStatus.toBeValidated:
      return S.current.decisionStatusToBeValidated;
  }
}

class Decision {
  final String id;
  String description;
  DecisionStatus status;

  DateTime initialDate;
  DateTime? dueDate;

  String? responsibleId;
  String? reporterId;
  List<String> assistantsIds;

  String? projectId;

  Decision({
    required this.id,
    required this.description,
    required this.status,
    required this.initialDate,
    required this.dueDate,
    required this.responsibleId,
    required this.reporterId,
    required this.assistantsIds,
    required this.projectId,
  });

  Decision.empty()
    : id = '',
      description = '',
      status = DecisionStatus.toBeValidated,
      initialDate = DateTime.now(),
      assistantsIds = [];

  Map<String, dynamic> toJson() {
    return {
      if (isIdValid(id)) 'id': id,
      'description': description,
      'status': status.name,
      'initialDate': initialDate.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      if (isIdValid(responsibleId)) 'responsibleId': responsibleId,
      if (isIdValid(reporterId)) 'reporterId': reporterId,
      'assistantsIds': assistantsIds,
      if (isIdValid(projectId)) 'projectId': projectId,
    };
  }

  Decision.fromJson(dynamic data)
    : id = data['id'],
      description = data['description'],
      status = DecisionStatus.values[data['status']],
      initialDate = DateTime.parse(data['initialDate']),
      dueDate =
          data['dueDate'] != null ? DateTime.parse(data['dueDate']) : null,
      responsibleId = data['responsibleId'],
      reporterId = data['reporterId'],
      assistantsIds =
          data['assistantsIds'] != null
              ? List<String>.from(data['assistantsIds'])
              : [],
      projectId = data['projectId'];
}
