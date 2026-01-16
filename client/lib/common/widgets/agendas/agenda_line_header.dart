import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:qfqq/common/models/meeting_agenda.dart';
import 'package:qfqq/generated/l10n.dart';

class AgendaLineHeader extends StatelessWidget {
  final MeetingAgenda agenda;

  const AgendaLineHeader({super.key, required this.agenda});

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);
    final agendaDateText =
        agenda.reunionDate != null
            ? DateFormat.yMMMd().format(agenda.reunionDate!)
            : loc.commonNoReunionDate;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(agenda.title, style: TextStyle(fontSize: 16)),
          const Spacer(),
          TextButton(
            child: Text(loc.commonView),
            onPressed: () => context.go('/agendas/${agenda.id}'),
          ),
          SizedBox(width: 8),
          TextButton(
            child: Text(loc.commonStart),
            onPressed: () => context.go('/meeting-in-progress/${agenda.id}'),
          ),
          SizedBox(width: 8),
          Text(
            agendaDateText,
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
