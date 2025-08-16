enum DecisionStatus {
  inProgress,
  cancelled,
  pending,
  completed,
  taskDescription,
  approved,
  toBeValidated,
}

class Decision {
  final String id;
  final String description;
  final DecisionStatus status;

  final DateTime initialDate;
  final DateTime? dueDate;

  final String responsibleId;
  final List<String> assistantsId;

  final String projectId;

  Decision({
    required this.id,
    required this.description,
    required this.status,
    required this.initialDate,
    required this.dueDate,
    required this.responsibleId,
    required this.assistantsId,
    required this.projectId,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'status': status.name,
      'initialDate': initialDate.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'responsibleId': responsibleId,
      'assistantsId': assistantsId,
      'projectId': projectId,
    };
  }
}