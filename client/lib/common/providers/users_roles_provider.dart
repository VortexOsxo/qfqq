import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/models/user_role.dart';
import 'package:qfqq/common/services/qfqq_http_client.dart';
import 'package:qfqq/common/services/users_roles_service.dart';

final usersRolesProvider = StateNotifierProvider<UsersRolesService, List<UserRole>>(
  (ref) => UsersRolesService(ref.read(qfqqHttpClientProvider)),
);

final userRoleByIdProvider = Provider.family<UserRole?, int>((ref, id) {
  final users = ref.watch(usersRolesProvider);
  return users.firstWhereOrNull((userRole) => userRole.userId == id);
});
