import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/services/auth_service.dart';
import 'package:qfqq/common/services/decisions_service.dart';
import 'package:qfqq/common/models/decision.dart';
import 'package:qfqq/common/services/qfqq_http_client.dart';

final decisionsProvider = StateNotifierProvider<DecisionsService, List<Decision>>(
  (ref) => DecisionsService(
    ref.read(qfqqHttpClientProvider),
    ref.read(authStateProvider.notifier),
  ),
);

final myResponsibilitiesProvider = Provider<List<Decision>>((ref) {
  final decisions = ref.watch(decisionsProvider);
  final userId = ref.watch(authStateProvider.select((state) => state.userId));
  if (userId == null) return [];

  return decisions.where((d) => d.responsibleId == userId).toList();
});


final decisionByIdProvider = Provider.family<Decision?, int>((ref, id) {
  final decisions = ref.watch(decisionsProvider);
  return decisions.firstWhereOrNull((d) => d.id == id);
});

final decisionsServiceProvider = Provider<DecisionsService>(
  (ref) => ref.read(decisionsProvider.notifier),
);
