import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:qfqq/common/models/meeting_agenda.dart';
import 'package:qfqq/common/providers/meeting_agendas_provider.dart';
import 'package:qfqq/generated/l10n.dart';

class AgendaLineHeader extends ConsumerWidget {
  final MeetingAgenda agenda;

  const AgendaLineHeader({super.key, required this.agenda});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = S.of(context);
    final agendaDateText =
        agenda.meetingDate != null
            ? DateFormat.yMMMd().format(agenda.meetingDate!)
            : loc.commonNoReunionDate;

    void startMeeting(agenda) async {
      final meetingsService = ref.read(meetingAgendaServiceProvider);

      await meetingsService.updateMeetingAgendaStatus(
        agenda.id,
        MeetingAgendaStatus.ongoing,
      );
      if (context.mounted) {
        context.go('/agendas/${agenda.id}');
      }
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(agenda.title, style: TextStyle(fontSize: 16)),
          const Spacer(),
          Text(
            agendaDateText,
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          SizedBox(width: 8),
          TextButton(
            child: Text(loc.commonView),
            onPressed: () => context.go('/agendas/${agenda.id}'),
          ),
          SizedBox(width: 8),
          TextButton(
            child: Text(loc.commonStart),
            onPressed: () => startMeeting(agenda),
          ),
        ],
      ),
    );
  }
}
