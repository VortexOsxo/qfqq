import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      return SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              S
                  .of(context)
                  .organizationFreeTrialEndsOn(
                    formatDateDay(context, info.trialEndsAt),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
