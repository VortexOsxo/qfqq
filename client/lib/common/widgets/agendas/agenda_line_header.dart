import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qfqq/common/models/meeting_agenda.dart';
import 'package:qfqq/common/utils/fromatting.dart';
import 'package:qfqq/common/utils/platform.dart';
import 'package:qfqq/common/widgets/navigation/navigation_arrow_icon.dart';
import 'package:qfqq/generated/l10n.dart';

class AgendaLineHeader extends ConsumerWidget {
  final MeetingAgenda agenda;

  const AgendaLineHeader({super.key, required this.agenda});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = S.of(context);
    final agendaDateText =
        agenda.meetingDate != null
            ? formatDate(context, agenda.meetingDate)
            : loc.commonNoReunionDate;

    Future<Object?> navigate() => context.push('/agendas/${agenda.id}');
    final viewButton = NavigationArrowIcon(tooltip: loc.commonView, onPressed: navigate);
    
    return InkWell(
      onTap: navigate,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final title = Text(
              agenda.title,
              style: TextStyle(fontSize: 16),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            );

            if (constraints.maxWidth < 600) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  title,
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          agendaDateText,
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (platformType != PlatformType.desktop) viewButton,
                    ],
                  ),
                ],
              );
            }

            return Row(
              children: [
                Expanded(child: title),
                const SizedBox(width: 8),
                Text(
                  agendaDateText,
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(width: 8),
                if (platformType != PlatformType.desktop) viewButton,
              ],
            );
          },
        ),
      ),
    );
  }
}
