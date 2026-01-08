import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/providers/decisions_provider.dart';
import 'package:qfqq/common/providers/fetcher_providers/decisions_responsabilities_fetcher_provider.dart';

final initializationProvider = Provider<int>((ref) {
  ref.read(decisionsResponsabilitiesFetcherProvider.notifier);
  ref.read(decisionsFetcherProvider.notifier);
  return 0;
});
