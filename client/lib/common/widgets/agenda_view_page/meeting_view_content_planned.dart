import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/models/meeting_agenda.dart';
import 'package:qfqq/common/services/auth_service.dart';
import 'package:qfqq/common/utils/help_util.dart';
import 'package:qfqq/common/widgets/help/help_button.dart';
import 'package:qfqq/generated/l10n.dart';

class MeetingViewContentPlanned extends ConsumerWidget {
  final MeetingAgenda meeting;

  const MeetingViewContentPlanned({super.key, required this.meeting});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = S.of(context);
    final currentUser = ref.watch(authStateProvider).user;
    final isAnimator = currentUser != null && meeting.animatorId == currentUser.id;

    final helpLink = isAnimator
            ? MeetingAnimationHelpLink(loc: loc)
            : MeetingParticipationHelpLink(loc: loc);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              loc.agendaStatusPlanned,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          HelpButton(helpLink: helpLink),
        ],
      ),
    );
  }
}
