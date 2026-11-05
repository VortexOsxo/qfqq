import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:qfqq/common/models/meeting_agenda.dart';
import 'package:qfqq/common/utils/fromatting.dart';
import 'package:qfqq/common/utils/get_status_ui.dart';
import 'package:qfqq/common/widgets/home_page/home_shortcut_header_widget.dart';
import 'package:qfqq/generated/l10n.dart';

class AgendaLineHeader extends StatelessWidget {
  final MeetingAgenda agenda;

  const AgendaLineHeader({super.key, required this.agenda});

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);
    final meetingDate = agenda.meetingDate?.toLocal();
    final isToday = DateUtils.dateOnly(meetingDate!) == DateUtils.dateOnly(DateTime.now());

    final meetingDateText = isToday
            ? loc.agendaMeetingTodayAt(
              DateFormat.Hm(
                Localizations.localeOf(context).toString(),
              ).format(meetingDate),
            )
            : formatDate(context, meetingDate);

    final statusUI = getMeetingAgendaStatusUI(loc, agenda.status);
    final style = agenda.status == MeetingAgendaStatus.ongoing
      ? HeaderStyle.urgent
      : isToday ? HeaderStyle.today : HeaderStyle.normal;

    return HomeShortcutHeaderWidget(
      description: agenda.title,
      style: style,
      statusText: statusUI.label,
      dateText: meetingDateText,
      navigate: () => context.push('/agendas/${agenda.id}'),
    );
  }
}
