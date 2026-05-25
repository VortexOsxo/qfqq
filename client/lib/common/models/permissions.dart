class Permissions {
  final bool canWrite;
  final bool canDelete;
  final bool canUpdatePermissions;

  Permissions({
    this.canWrite = false,
    this.canDelete = false,
    this.canUpdatePermissions = false,
  });

  Permissions.fromJson(dynamic data)
    : canWrite = data != null ? (data['canWrite'] ?? false) : false,
      canDelete = data != null ? (data['canDelete'] ?? false) : false,
      canUpdatePermissions = data != null ? (data['canUpdatePermissions'] ?? false) : false;

  bool respect(Permissions neededPermissions) {
    if (neededPermissions.canWrite && !canWrite) {
      return false;
    }

    if (neededPermissions.canDelete && !canDelete) {
      return false;
    }

    if (neededPermissions.canUpdatePermissions && !canUpdatePermissions) {
      return false;
    }

    return true;
  }
}
