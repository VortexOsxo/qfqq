import 'package:qfqq/common/utils/is_id_valid.dart';

class Project {
  final String id;
  final int number;
  String title;
  String goals;
  String supervisorId;

  Project({
    this.id = '',
    this.number = 0,
    required this.title,
    required this.goals,
    required this.supervisorId,
  });

  Project.empty()
    : id = '',
      number = 0,
      title = '',
      goals = '',
      supervisorId = '';

  Project.fromJson(dynamic data)
    : id = data['id'],
      number = data['number'],
      title = data['title'],
      goals = data['goals'],
      supervisorId = data['supervisorId'];

  Map<String, dynamic> toJson() {
    return {
      if (isIdValid(id)) 'id': id,
      if (number != 0) 'number': number,
      'title': title,
      'goals': goals,
      'supervisorId': supervisorId,
    };
  }
}
