import 'package:qfqq/common/utils/is_id_valid.dart';

class Role {
  final int id;
  String name;
  bool canWrite;
  bool canDelete;
  bool canUpdatePermissions;


  Role({
    this.id = 0,
    this.name = "",
    this.canWrite = false,
    this.canDelete = false,
    this.canUpdatePermissions = false,
  });

  Role.fromJson(dynamic data)
    : id = data['id'],
      name = data['name'],
      canWrite = data['canWrite'],
      canDelete = data['canDelete'],
      canUpdatePermissions = data['canUpdatePermissions'];

  Map<String, dynamic> toJson() {
    return {
      if (isIdValid(id)) 'id': id,
      'name': name,
      'canWrite': canWrite,
      'canDelete': canDelete,
      'canUpdatePermissions': canUpdatePermissions,
    };
  }
}
