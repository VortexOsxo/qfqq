import 'package:qfqq/common/utils/is_id_valid.dart';

class Project {
  final int id;
  final int number;
  String title;
  String goals;
  int supervisorId;

  Project({
    this.id = 0,
    this.number = 0,
    required this.title,
    required this.goals,
    required this.supervisorId,
  });

  Project.empty()
    : id = 0,
      number = 0,
      title = '',
      goals = '',
      supervisorId = 0;

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
