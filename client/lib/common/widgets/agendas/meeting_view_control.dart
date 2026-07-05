import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qfqq/common/models/meeting_agenda.dart';
import 'package:qfqq/common/models/permissions.dart';
import 'package:qfqq/common/providers/meeting_agendas_provider.dart';
import 'package:qfqq/common/services/meeting_agenda_service.dart';
import 'package:qfqq/common/services/modal_service.dart';
import 'package:qfqq/common/utils/platform.dart';
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
      context: context,
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
    final service = ref.read(meetingAgendaServiceProvider);

    bool isDesktop = platformType == PlatformType.desktop;

    List<Widget> buttons = [];
    switch (meeting.status) {
      case MeetingAgendaStatus.draft:
        buttons = [
          if (isDesktop) _modifyButton(context, ref),
          _markAsPlannedButton(context, service),
        ];
      case MeetingAgendaStatus.planned:
        buttons = [
          if (isDesktop) _modifyButton(context, ref),
          _startButton(context, service),
        ];
      case MeetingAgendaStatus.ongoing:
        buttons = [
          if (isDesktop) _nextMeetingButton(context),
          _completeButton(context, service),
        ];
      case MeetingAgendaStatus.completed:
    }

    if (isDesktop) {
      buttons.add(_deleteButton(context, ref));
    }

    if (buttons.isEmpty) {
      return SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: buttons,
    );
  }

  Widget _modifyButton(BuildContext context, WidgetRef ref) {
    return PermissionRequired(
      neededPermissions: Permissions(contribute: true),
      child: TextButton(
        onPressed: () => context.go('/agendas/creation', extra: meeting),
        child: Text(S.of(context).commonModify),
      ),
    );
  }

  Widget _markAsPlannedButton(BuildContext context, MeetingAgendaService service) {
    final errors = validateMeetingAgenda(meeting, wantedStatus: MeetingAgendaStatus.planned);

    return TextButton(
      onPressed:
          errors.hasAny()
              ? null
              : () => service.updateMeetingAgendaStatus(
                meeting.id,
                MeetingAgendaStatus.planned,
              ),
      child: Text(S.of(context).meetingViewControlPlan),
    );
  }

  Widget _startButton(BuildContext context, MeetingAgendaService service) {
    return TextButton(
      child: Text(S.of(context).commonStart),
      onPressed: () => service.startMeeting(meeting.id),
    );
  }

  Widget _completeButton(BuildContext context, MeetingAgendaService service) {
    return TextButton(
        child: Text(S.of(context).meetingViewControlTerminate),
        onPressed: () => service.completeMeeting(meeting.id),
    );
  }

  Widget _nextMeetingButton(BuildContext context) {
    return TextButton(
      child: Text(S.of(context).agendaNextCreation),
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
    );
  }        

  Widget _deleteButton(BuildContext context, WidgetRef ref) {
    return PermissionRequired(
      neededPermissions: Permissions(deleteContent: true),
      child: TextButton(
        onPressed: () => deleteAgenda(context, ref),
        child: Text(S.of(context).commonDelete),
      ),
    );
  }
}
