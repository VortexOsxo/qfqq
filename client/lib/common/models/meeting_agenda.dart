enum MeetingAgendaStatus { draft, planned, completed }

class MeetingAgenda {
  final String id;
  int number;
  String title;
  String? goals;
  MeetingAgendaStatus status;

  final DateTime redactionDate;

  DateTime? meetingDate;
  String? meetingLocation;

  String? animatorId;
  List<String> participantsIds = [];

  List<String> themes = [];
  String? projectId;

  MeetingAgenda({
    this.id = '',
    this.number = 0,
    required this.title,
    required this.redactionDate,
    required this.status,
    this.goals = '',
  });

  MeetingAgenda.empty()
    : id = '',
      number = 0,
      title = '',
      goals = '',
      status = MeetingAgendaStatus.draft,
      redactionDate = DateTime.now();

  @override
  bool operator ==(Object other) {
    if (other is! MeetingAgenda) return false;
    return id == other.id;
  }

  @override
  int get hashCode => id.hashCode;

  MeetingAgenda.fromJson(dynamic data)
    : id = data['id'],
      number = data['number'],
      title = data['title'],
      goals = data['goals'],
      redactionDate = DateTime.parse(data['redactionDate']),
      status = MeetingAgendaStatus.values.firstWhere(
        (e) => e.toString().split('.').last == data['status'],
      ),
      meetingDate =
          data['meetingDate'] != null
              ? DateTime.parse(data['meetingDate'])
              : null,
      meetingLocation = data['meetingLocation'],
      animatorId = data['animatorId'],
      participantsIds = List<String>.from(data['participantsIds']),
      themes = List<String>.from(data['themes']),
      projectId = data['projectId'];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'number': number,
      'title': title,
      'redactionDate': redactionDate.toIso8601String(),
      'status': status.toString().split('.').last,

      if (goals != null) 'goals': goals,
      if (meetingDate != null) 'reunionDate': meetingDate!.toIso8601String(),
      if (meetingLocation != null) 'reunionLocation': meetingLocation,
      if (animatorId != null) 'animatorId': animatorId,
      if (participantsIds.isNotEmpty) 'participantsIds': participantsIds,
      if (themes.isNotEmpty) 'themes': themes,
      if (projectId != null) 'projectId': projectId,
    };
  }
}
