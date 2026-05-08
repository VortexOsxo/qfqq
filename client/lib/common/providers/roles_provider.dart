import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/models/role.dart';
import 'package:qfqq/common/services/qfqq_http_client.dart';
import 'package:qfqq/common/services/roles_service.dart';

final rolesProvider = StateNotifierProvider<RolesService, List<Role>>(
  (ref) => RolesService(ref.read(qfqqHttpClientProvider)),
);

