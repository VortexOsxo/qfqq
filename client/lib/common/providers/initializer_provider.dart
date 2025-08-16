import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/providers/decisions_provider.dart';

final initializationProvider = Provider<int>((ref) {
  ref.read(decisionsServiceProvider);
  return 0;
});
