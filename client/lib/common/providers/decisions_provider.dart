import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/providers/server_url.dart';
import 'package:qfqq/common/services/auth_service.dart';
import 'package:qfqq/common/services/decisions_service.dart';

final decisionsServiceProvider = Provider<DecisionsService>(
  (ref) => DecisionsService(
    ref.read(serverUrlProvider),
    ref.read(authStateProvider.notifier),
  ),
);
