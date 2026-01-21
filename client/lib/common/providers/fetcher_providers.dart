import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/models/decision.dart';
import 'package:qfqq/common/models/meeting_agenda.dart';
import 'package:qfqq/common/providers/decisions_provider.dart';
import 'package:qfqq/common/providers/meeting_agendas_provider.dart';
import 'package:qfqq/common/services/auth_service.dart';
import 'package:qfqq/common/services/fetcher_services/base_fetcher_service.dart';
import 'package:qfqq/common/services/fetcher_services/decisions_responsabilities_fetcher_service.dart';
import 'package:qfqq/common/services/fetcher_services/user_meetings_fetcher_service.dart';

final decisionsResponsabilitiesFetcherProvider = StateNotifierProvider<
  DecisionsResponsabilitiesFetcherService,
  FetcherState<List<Decision>>
>(
  (ref) => DecisionsResponsabilitiesFetcherService(
    ref.read(decisionsServiceProvider),
    ref.read(authStateProvider.notifier),
  ),
);

final userMeetingsFetcherService = StateNotifierProvider<
  UserMeetingsFetcherService,
  FetcherState<List<MeetingAgenda>>
>(
  (ref) => UserMeetingsFetcherService(
    ref.read(meetingAgendaServiceProvider),
    ref.read(authStateProvider.notifier),
  ),
);