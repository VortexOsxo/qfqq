enum MeetingAgendaStatus { draft, planned, completed }

class MeetingAgenda {
  final String id;
  String title;
  String reunionGoals;
  MeetingAgendaStatus status;

  final DateTime redactionDate;

  DateTime? reunionDate;
  String? reunionLocation;

  String? animatorId;
  List<String> participantsIds = [];

  List<String> themes = [];
  String? projectId;

  MeetingAgenda({
    this.id = '',
    required this.title,
    required this.redactionDate,
    required this.status,
    this.reunionGoals = '',
  });

  MeetingAgenda.empty()
    : id = '',
      title = '',
      reunionGoals = '',
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
      title = data['title'],
      reunionGoals = data['reunionGoals'],
      redactionDate = DateTime.parse(data['redactionDate']),
      status = MeetingAgendaStatus.values.firstWhere(
        (e) => e.toString().split('.').last == data['status'],
      ),
      reunionDate =
          data['reunionDate'] != null
              ? DateTime.parse(data['reunionDate'])
              : null,
      reunionLocation = data['reunionLocation'],
      animatorId = data['animatorId'],
      participantsIds = List<String>.from(data['participantsIds']),
      themes = List<String>.from(data['themes']),
      projectId = data['projectId'];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'reunionGoals': reunionGoals,
      'redactionDate': redactionDate.toIso8601String(),
      'status': status.toString().split('.').last,

      if (reunionDate != null) 'reunionDate': reunionDate!.toIso8601String(),
      if (reunionLocation != null) 'reunionLocation': reunionLocation,
      if (animatorId != null) 'animatorId': animatorId,
      if (participantsIds.isNotEmpty) 'participantsIds': participantsIds,
      if (themes.isNotEmpty) 'themes': themes,
      if (projectId != null) 'projectId': projectId,
    };
  }
}
