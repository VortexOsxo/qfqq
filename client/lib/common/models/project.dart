import 'package:qfqq/common/utils/is_id_valid.dart';

enum ProjectStatus { inProgress, completed }

class Project {
  final int id;
  final int number;
  String title;
  String goals;
  ProjectStatus status;
  int supervisorId;

  Project({
    this.id = 0,
    this.number = 0,
    required this.title,
    required this.goals,
    required this.status,
    required this.supervisorId,
  });

  Project.empty()
    : id = 0,
      number = 0,
      title = '',
      goals = '',
      status = ProjectStatus.inProgress,
      supervisorId = 0;

  Project.fromJson(dynamic data)
    : id = data['id'],
      number = data['number'],
      title = data['title'],
      goals = data['goals'],
      status = ProjectStatus.values.firstWhere(
        (e) => e.toString().split('.').last == data['status'],
      ),
      supervisorId = data['supervisorId'];

  Map<String, dynamic> toJson() {
    return {
      if (isIdValid(id)) 'id': id,
      if (number != 0) 'number': number,
      'title': title,
      'goals': goals,
      'status': status.toString(),
      'supervisorId': supervisorId,
    };
  }

  Project copy() {
    return Project(
      id: id,
      number: number,
      title: title,
      goals: goals,
      status: status,
      supervisorId: supervisorId,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is Project &&
           other.id == id &&
           other.number == number &&
           other.title == title &&
           other.goals == goals &&
           other.status == status &&
           other.supervisorId == supervisorId;
  }

  @override
  int get hashCode =>
      id.hashCode ^
      number.hashCode ^
      title.hashCode ^
      goals.hashCode ^
      status.hashCode ^
      supervisorId.hashCode;
}
