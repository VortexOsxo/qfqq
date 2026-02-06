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
  int id;
  int number;
  String description;
  DecisionStatus status;

  DateTime initialDate;
  DateTime? dueDate;
  DateTime? completedDate;

  int? responsibleId;
  int? meetingId;

  List<int> assistantsIds;
  int? projectId;

  Decision({
    required this.id,
    required this.number,
    required this.description,
    required this.status,
    required this.initialDate,
    required this.dueDate,
    required this.completedDate,
    required this.responsibleId,
    required this.meetingId,
    required this.assistantsIds,
    required this.projectId,
  });

  Decision.empty()
    : id = 0,
      number = 0,
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
      if (dueDate != null) 'dueDate': dueDate?.toIso8601String(),
      if (completedDate != null) 'completedDate': completedDate?.toIso8601String(),
      if (isIdValid(responsibleId)) 'responsibleId': responsibleId,
      if (isIdValid(meetingId)) 'meetingId': meetingId,
      'assistantsIds': assistantsIds,
      if (isIdValid(projectId)) 'projectId': projectId,
    };
  }

  Decision.fromJson(dynamic data)
    : id = data['id'],
      number = data['number'],
      description = data['description'],
      status = DecisionStatus.values.firstWhere(
        (e) => e.toString().split('.').last == data['status'],
      ),
      initialDate = DateTime.parse(data['initialDate']),
      completedDate = data['completedDate'] != null ? DateTime.parse(data['completedDate']) : null,
      dueDate =
          data['dueDate'] != null ? DateTime.parse(data['dueDate']) : null,
      responsibleId = data['responsibleId'],
      meetingId = data['meetingId'],
      assistantsIds =
          data['assistantsIds'] != null
              ? List<int>.from(data['assistantsIds'])
              : [],
      projectId = data['projectId'];
}
