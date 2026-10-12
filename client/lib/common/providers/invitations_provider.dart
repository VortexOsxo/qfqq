import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/models/invitation.dart';
import 'package:qfqq/common/providers/users_provider.dart';
import 'package:qfqq/common/providers/users_roles_provider.dart';
import 'package:qfqq/common/services/auth_service.dart';
import 'package:qfqq/common/services/invitation_service.dart';
import 'package:qfqq/common/services/qfqq_http_client.dart';

final invitationsProvider = StateNotifierProvider<InvitationsService, List<Invitation>>(
  (ref) => InvitationsService(
    ref.read(qfqqHttpClientProvider),
    () {
      final authState = ref.read(authStateProvider); 
      ref.read(usersProvider.notifier).loadUsers();
      ref.read(usersRolesProvider.notifier).loadRoles(authState);
    },
    ref.read(authStateProvider.notifier),
  ),
);
