import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qfqq/common/services/auth_service.dart';

final allowedRoutesNoAccount = {'/login', '/signup', '/forgotten-password'};
final allowedRoutesNoOrg = allowedRoutesNoAccount.union({
  '/organizations/links',
});

String? redirect(Ref ref, BuildContext context, GoRouterState state) {
  final authState = ref.read(authStateProvider);
  final loc = state.matchedLocation;

  if (!authState.isAuthenticated && !allowedRoutesNoAccount.contains(loc)) {
    return '/login';
  }

  if (!authState.hasOrg && !allowedRoutesNoOrg.contains(loc)) {
    return '/organizations/links';
  }

  return null;
}
