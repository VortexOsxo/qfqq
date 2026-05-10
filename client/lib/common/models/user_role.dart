class UserRole {
  final int userId;
  final int roleId;
  String roleName;

  UserRole({
    required this.userId,
    required this.roleId,
    required this.roleName
  });

  UserRole.fromJson(dynamic data)
    : userId = data['userId'],
      roleId = data['roleId'],
      roleName = data['roleName'];

  UserRole copyWith({
    int? userId,
    int? roleId,
    String? roleName,
  }) {
    return UserRole(
      userId: userId ?? this.userId,
      roleId: roleId ?? this.roleId,
      roleName: roleName ?? this.roleName,
    );
  }
}
