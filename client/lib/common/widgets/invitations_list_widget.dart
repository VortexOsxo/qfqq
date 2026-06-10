import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/providers/invitations_provider.dart';
import 'package:qfqq/common/templates/card_template.dart';
import 'package:qfqq/generated/l10n.dart';

class InvitationsListWidget extends ConsumerWidget {
  const InvitationsListWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final loc = S.of(context);
    final invitations = ref.read(invitationsProvider);

    Widget cardContent = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            SizedBox(width: 16),
            Expanded(flex: 1, child: Text(loc.attributeEmail)),
            Expanded(flex: 1, child: Text(loc.commonRole)),
            SizedBox(width: 16),
          ],
        ),
        Divider(color: theme.colorScheme.primary, thickness: 2),
        Expanded(
          child: ListView.separated(
            itemCount: invitations.length,
            separatorBuilder: (BuildContext context, int index) => const Divider(),
            itemBuilder: (context, index) {
              final invitation = invitations[index];

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(width: 16),
                  Expanded(flex: 1, child: Text(invitation.email)),
                  Expanded(flex: 1, child: Text(invitation.roleId.toString())),
                  SizedBox(width: 16),
                ],
              );
            },
          ),
        ),
      ],
    );
    return buildContentListCardTemplate(cardContent);
  }
}
