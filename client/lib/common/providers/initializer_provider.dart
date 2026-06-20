import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/providers/decisions_provider.dart';
import 'package:qfqq/common/providers/invitations_provider.dart';
import 'package:qfqq/common/providers/meeting_agendas_provider.dart';
import 'package:qfqq/common/providers/projects_provider.dart';
import 'package:qfqq/common/providers/users_provider.dart';
import 'package:qfqq/common/services/web_socket_service.dart';

final initializationProvider = Provider<int>((ref) {
  ref.read(decisionsProvider.notifier);
  ref.read(projectsProvider.notifier);
  ref.read(usersProvider.notifier);
  ref.read(meetingsAgendasProvider.notifier);
  ref.read(invitationsProvider.notifier);

  WebSocketService.connect();
  return 0;
});
