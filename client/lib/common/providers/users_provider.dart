import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/models/user.dart';
import 'package:qfqq/common/services/auth_service.dart';
import 'package:qfqq/common/services/qfqq_http_client.dart';
import 'package:qfqq/common/services/users_service.dart';

final usersProvider = StateNotifierProvider<UsersService, List<User>>(
  (ref) => UsersService(
    ref.read(qfqqHttpClientProvider),
    ref.read(authStateProvider.notifier),
  ),
);

final userByIdProvider = Provider.family<User?, int>((ref, id) {
  final users = ref.watch(usersProvider);
  return users.firstWhereOrNull((user) => user.id == id);
});

final userServiceProvider = Provider<UsersService>(
  (ref) => ref.read(usersProvider.notifier),
);
