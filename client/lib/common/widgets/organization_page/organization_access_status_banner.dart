import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qfqq/common/services/organization_service.dart';
import 'package:qfqq/common/utils/fromatting.dart';
import 'package:qfqq/generated/l10n.dart';

class OrganizationAccessStatusBanner extends ConsumerWidget {
  const OrganizationAccessStatusBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accessInfo = ref.watch(organizationAccessStatusProvider);

    return accessInfo.when(
      loading: () => const SizedBox.shrink(),
      error: (error, stackTrace) => const SizedBox.shrink(),
      data: (info) => buildInternal(context, info),
    );
  }

  Widget buildInternal(BuildContext context, OrganizationAccessInfo? info) {
    if (info == null || info.status != 'freeTrialAccess') {
      return const SizedBox.shrink();
    }

    final loc = S.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              loc.organizationFreeTrialEndsOn(
                formatDateDay(context, info.trialEndsAt),
              ),
            ),
          ),
          TextButton.icon(
            onPressed: () => context.go('/organization/subscription'),
            icon: const Icon(Icons.contact_support_outlined),
            label: Text(loc.subscribePageTitle),
          ),
        ],
      ),
    );
  }
}
