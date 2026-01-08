import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/providers/server_url.dart';
import 'package:qfqq/common/services/auth_service.dart';
import 'package:qfqq/common/services/decisions_service.dart';
import 'package:qfqq/common/models/decision.dart';
import 'package:qfqq/common/services/fetcher_services/base_fetcher_service.dart';
import 'package:qfqq/common/services/fetcher_services/decisions_fetcher_service.dart';

final decisionsServiceProvider = Provider<DecisionsService>(
  (ref) => DecisionsService(
    ref.read(serverUrlProvider),
    ref.read(authStateProvider.notifier),
  ),
);

final decisionsFetcherProvider = StateNotifierProvider<
  DecisionsFercherService,
  FetcherState<List<Decision>>
>(
  (ref) => DecisionsFercherService(
    ref.read(decisionsServiceProvider),
    ref.read(authStateProvider.notifier),
  ),
);
