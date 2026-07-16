import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:qfqq/common/models/meeting_agenda.dart';
import 'package:qfqq/common/theme/styles.dart';
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

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              agenda.title,
              style: TextStyle(fontSize: 16),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            agendaDateText,
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(width: 8),
          TextButton(
            style: inplaceTextButtonStyle(context),
            child: Text(loc.commonView),
            onPressed: () => context.go('/agendas/${agenda.id}'),
          ),
        ],
      ),
    );
  }
}
