class Invitation {
  int orgId;
  String email;
  int roleId;

  Invitation({required this.orgId, required this.email, required this.roleId});

  Invitation.fromJson(dynamic data)
    : orgId = data['orgId'],
      email = data['email'],
      roleId = data['roleId'];
}
