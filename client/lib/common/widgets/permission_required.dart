import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/models/permissions.dart';
import 'package:qfqq/common/services/auth_service.dart';

class PermissionRequired extends ConsumerWidget {
  final Widget child;
  final Permissions neededPermissions;

  const PermissionRequired({
    super.key,
    required this.child,
    required this.neededPermissions,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userPermissions = ref.watch(authStateProvider.select((state) => state.permissions));
    if (userPermissions == null || !userPermissions.respect(neededPermissions)) {
      return SizedBox.shrink();
    }

    return child;
  }
}