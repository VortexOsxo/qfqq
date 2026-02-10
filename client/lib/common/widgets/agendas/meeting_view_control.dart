import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qfqq/common/models/meeting_agenda.dart';
import 'package:qfqq/generated/l10n.dart';

class MeetingViewControl extends ConsumerWidget {
  final MeetingAgenda meeting;
  const MeetingViewControl({super.key, required this.meeting});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = S.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextButton(
          child: Text(loc.commonModify),
          onPressed: () => context.go('/agenda', extra: meeting),
        ),
        TextButton(
          child: Text(loc.commonStart),
          onPressed: () => context.go('/meeting-in-progress/${meeting.id}'),
        ),
      ],
    );
  }
}
