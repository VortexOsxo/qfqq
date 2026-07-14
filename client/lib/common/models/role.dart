import 'package:qfqq/common/utils/is_id_valid.dart';

class Role {
  final int id;
  String name;
  bool contribute;
  bool deleteContent;
  bool manageTeam;


  Role({
    this.id = 0,
    this.name = "",
    this.contribute = false,
    this.deleteContent = false,
    this.manageTeam = false,
  });

  Role.fromJson(dynamic data)
    : id = data['id'],
      name = data['name'],
      contribute = data['contribute'],
      deleteContent = data['deleteContent'],
      manageTeam = data['manageTeam'];

  Map<String, dynamic> toJson() {
    return {
      if (isIdValid(id)) 'id': id,
      'name': name,
      'contribute': contribute,
      'deleteContent': deleteContent,
      'manageTeam': manageTeam,
    };
  }
}
