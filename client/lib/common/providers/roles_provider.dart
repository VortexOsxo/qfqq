import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/models/role.dart';
import 'package:qfqq/common/services/qfqq_http_client.dart';
import 'package:qfqq/common/services/roles_service.dart';

final rolesProvider = StateNotifierProvider<RolesService, List<Role>>(
  (ref) => RolesService(ref.read(qfqqHttpClientProvider)),
);

final roleByIdProvider = Provider.family<Role?, int>((ref, id) {
  final roles = ref.watch(rolesProvider);
  return roles.firstWhereOrNull((role) => role.id == id);
});
