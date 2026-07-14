import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/providers/decisions_provider.dart';
import 'package:qfqq/common/providers/invitations_provider.dart';
import 'package:qfqq/common/providers/meeting_agendas_provider.dart';
import 'package:qfqq/common/providers/projects_provider.dart';
import 'package:qfqq/common/providers/users_provider.dart';
import 'package:qfqq/common/services/push_notification_service.dart';
import 'package:qfqq/common/utils/platform.dart';

final initializationProvider = Provider<int>((ref) {
  ref.read(decisionsProvider.notifier);
  ref.read(projectsProvider.notifier);
  ref.read(usersProvider.notifier);
  ref.read(meetingsAgendasProvider.notifier);
  ref.read(invitationsProvider.notifier);

  if (platformType == PlatformType.mobile) {
    ref.read(pushNotificationServiceProvider);
  }
  
  return 0;
});
