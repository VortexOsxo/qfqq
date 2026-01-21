import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/providers/decisions_provider.dart';
import 'package:qfqq/common/providers/fetcher_providers.dart';

final initializationProvider = Provider<int>((ref) {
  ref.read(decisionsResponsabilitiesFetcherProvider.notifier);
  ref.read(decisionsFetcherProvider.notifier);
  ref.read(userMeetingsFetcherService.notifier);
  return 0;
});
