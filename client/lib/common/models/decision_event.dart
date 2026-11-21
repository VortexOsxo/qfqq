enum DecisionEventType { decisionCreated, statusUpdated }

class DecisionEvent {
  final int decisionId;
  final int userId;
  final DateTime date;
  final DecisionEventType type;
  final Map<String, dynamic>? data;

  const DecisionEvent({
    required this.decisionId,
    required this.userId,
    required this.date,
    required this.type,
    required this.data,
  });

  factory DecisionEvent.fromJson(Map<String, dynamic> json) {
    return DecisionEvent(
      decisionId: json['decisionId'] as int,
      userId: json['userId'] as int,
      date: DateTime.parse(json['date'] as String),
      type: DecisionEventType.values.byName(json['type'] as String),
      data: json['data'] as Map<String, dynamic>?,
    );
  }
}
