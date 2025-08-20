import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/models/decision.dart';
import 'package:qfqq/common/providers/decisions_provider.dart';
import 'package:qfqq/common/services/auth_service.dart';
import 'package:qfqq/common/services/fetcher_services/base_fetcher_service.dart';
import 'package:qfqq/common/services/fetcher_services/decisions_responsabilities_fetcher_service.dart';

final decisionsResponsabilitiesFetcherProvider = StateNotifierProvider<
  DecisionsResponsabilitiesFetcherService,
  FetcherState<List<Decision>>
>(
  (ref) => DecisionsResponsabilitiesFetcherService(
    ref.read(decisionsServiceProvider),
    ref.read(authStateProvider.notifier),
  ),
);
