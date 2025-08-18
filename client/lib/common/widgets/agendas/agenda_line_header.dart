import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qfqq/common/models/meeting_agenda.dart';

class AgendaLineHeader extends StatelessWidget {
  final MeetingAgenda agenda;

  const AgendaLineHeader({super.key, required this.agenda});

  @override
  Widget build(BuildContext context) {
    final agendaDateText =
        agenda.reunionDate != null
            ? DateFormat.yMMMd().format(agenda.reunionDate!)
            : 'No reunion date';

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(agenda.title, style: TextStyle(fontSize: 16)),
          Text(
            agendaDateText,
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
