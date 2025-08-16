import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/models/user.dart';
import 'package:qfqq/common/providers/server_url.dart';
import 'package:qfqq/common/services/users_service.dart';

final usersProvider = StateNotifierProvider<UsersService, List<User>>(
  (ref) => UsersService(ref.read(serverUrlProvider)),
);

final userServiceProvider = Provider<UsersService>((ref) =>ref.read(usersProvider.notifier));
