enum MeetingAgendaStatus { draft, planned, ongoing, completed }

class MeetingAgenda {
  final int id;
  int number;
  String title;
  String? goals;
  MeetingAgendaStatus status;

  final DateTime redactionDate;
  DateTime? meetingDate;
  String? meetingLocation;

  int? animatorId;
  int? projectId;

  List<int> participantsIds = [];
  List<String> themes = [];

  MeetingAgenda({
    this.id = 0,
    this.number = 0,
    required this.title,
    required this.redactionDate,
    required this.status,
    this.goals = '',
  });

  MeetingAgenda.empty()
    : id = 0,
      number = 0,
      title = '',
      goals = '',
      status = MeetingAgendaStatus.draft,
      redactionDate = DateTime.now();

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
      participantsIds = List<int>.from(data['participantsIds']),
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
      if (meetingDate != null) 'meetingDate': meetingDate!.toIso8601String(),
      if (meetingLocation != null) 'meetingLocation': meetingLocation,
      if (animatorId != null) 'animatorId': animatorId,
      if (participantsIds.isNotEmpty) 'participantsIds': participantsIds,
      if (themes.isNotEmpty) 'themes': themes,
      if (projectId != null) 'projectId': projectId,
    };
  }
}
