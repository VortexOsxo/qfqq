class Permissions {
  final bool canWrite;
  final bool canDelete;
  final bool canUpdatePermissions;

  Permissions({
    required this.canWrite,
    required this.canDelete,
    required this.canUpdatePermissions,
  });

  Permissions.fromJson(dynamic data)
    : canWrite = data['canWrite'],
      canDelete = data['canDelete'],
      canUpdatePermissions = data['canUpdatePermissions'];
}
