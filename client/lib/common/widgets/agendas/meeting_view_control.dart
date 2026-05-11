import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qfqq/common/models/meeting_agenda.dart';
import 'package:qfqq/common/models/permissions.dart';
import 'package:qfqq/common/providers/meeting_agendas_provider.dart';
import 'package:qfqq/common/services/modal_service.dart';
import 'package:qfqq/common/utils/validation.dart';
import 'package:qfqq/common/widgets/agendas/agenda_next_creation.dart';
import 'package:qfqq/common/widgets/permission_required.dart';
import 'package:qfqq/generated/l10n.dart';

class MeetingViewControl extends ConsumerWidget {
  final MeetingAgenda meeting;
  const MeetingViewControl({super.key, required this.meeting});

  void deleteAgenda(BuildContext context, WidgetRef ref) async {
    var meetingAgendaService = ref.read(meetingAgendaServiceProvider);

    final loc = S.of(context);

    var result = await ModalService.showConfirmation(
      context,
      title: loc.agendaDeleteTitle,
      message: loc.agendaDeleteMessage,
      confirmLabel: loc.agendaDeleteConfirm,
      cancelLabel: loc.commonCancel,
    );

    if (result) {
      bool success = await meetingAgendaService.deleteMeetingAgenda(meeting.id);
      if (context.mounted && success) {
        context.go('/agendas');
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<Widget> buttons = [];

    switch (meeting.status) {
      case MeetingAgendaStatus.draft:
        buttons = draftButtons(context, ref);
      case MeetingAgendaStatus.planned:
        buttons = plannedButtons(context, ref);
      case MeetingAgendaStatus.ongoing:
        buttons = ongoingButtons(context, ref);
      case MeetingAgendaStatus.completed:
    }

    buttons.add(
      PermissionRequired(
        neededPermissions: Permissions(canDelete: true),
        child: TextButton(
          onPressed: () => deleteAgenda(context, ref),
          child: Text(S.of(context).commonDelete),
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: buttons,
    );
  }

  List<Widget> draftButtons(BuildContext context, WidgetRef ref) {
    final loc = S.of(context);

    final errors = validateMeetingAgenda(
      meeting,
      wantedStatus: MeetingAgendaStatus.planned,
    );

    final meetingsService = ref.read(meetingAgendaServiceProvider);

    return [
      TextButton(
        onPressed: () => context.go('/agenda', extra: meeting),
        child: Text(loc.commonModify),
      ),
      TextButton(
        onPressed:
            errors.hasAny()
                ? null
                : () => meetingsService.updateMeetingAgendaStatus(
                  meeting.id,
                  MeetingAgendaStatus.planned,
                ),
        child: Text(loc.meetingViewControlPlan),
      ),
    ];
  }

  List<Widget> plannedButtons(BuildContext context, WidgetRef ref) {
    final loc = S.of(context);

    final meetingsService = ref.read(meetingAgendaServiceProvider);

    return [
      TextButton(
        child: Text(loc.commonModify),
        onPressed: () => context.go('/agenda', extra: meeting),
      ),
      TextButton(
        child: Text(loc.commonStart),
        onPressed:
            () => meetingsService.updateMeetingAgendaStatus(
              meeting.id,
              MeetingAgendaStatus.ongoing,
            ),
      ),
    ];
  }

  List<Widget> ongoingButtons(BuildContext context, WidgetRef ref) {
    final loc = S.of(context);

    final meetingsService = ref.read(meetingAgendaServiceProvider);

    return [
      TextButton(
        child: Text(loc.agendaNextCreation),
        onPressed: () {
          var nextMeeting = meeting.copyWith(
            newStatus: MeetingAgendaStatus.planned,
          );
          nextMeeting.meetingDate = null;

          showDialog(
            context: context,
            barrierDismissible: true,
            builder: (_) => AgendaNextCreation(agenda: nextMeeting),
          );
        },
      ),
      TextButton(
        child: Text(loc.meetingViewControlTerminate),
        onPressed:
            () => meetingsService.updateMeetingAgendaStatus(
              meeting.id,
              MeetingAgendaStatus.completed,
            ),
      ),
    ];
  }
}
