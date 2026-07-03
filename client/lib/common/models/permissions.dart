class Permissions {
  final bool contribute;
  final bool deleteContent;
  final bool manageTeam;

  Permissions({
    this.contribute = false,
    this.deleteContent = false,
    this.manageTeam = false,
  });

  Permissions.fromJson(dynamic data)
    : contribute = data != null ? (data['contribute'] ?? false) : false,
      deleteContent = data != null ? (data['deleteContent'] ?? false) : false,
      manageTeam = data != null ? (data['manageTeam'] ?? false) : false;

  bool respect(Permissions neededPermissions) {
    if (neededPermissions.contribute && !contribute) {
      return false;
    }

    if (neededPermissions.deleteContent && !deleteContent) {
      return false;
    }

    if (neededPermissions.manageTeam && !manageTeam) {
      return false;
    }

    return true;
  }
}
