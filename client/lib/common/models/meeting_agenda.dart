enum 
MeetingAgendaStatus {
  created,
  saved,
  validated,
}

class MeetingAgenda {
  final String title;
  String reunionGoals;
  final MeetingAgendaStatus status;

  final DateTime redactionDate;
  
  DateTime? reunionDate;
  String? reunionLocation;

  String? animator;
  List<String> participants = [];

  List<String> themes = [];
  String project = '';

  MeetingAgenda({
    required this.title,
    required this.redactionDate,
    required this.status,
    this.reunionGoals = '',
  });
}