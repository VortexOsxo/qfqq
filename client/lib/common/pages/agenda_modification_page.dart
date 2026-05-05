import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qfqq/common/templates/form_template.dart';
import 'package:qfqq/common/templates/navigation_guard.dart';
import 'package:qfqq/common/models/errors/meeting_agenda_errors.dart';
import 'package:qfqq/common/services/modal_service.dart';
import 'package:qfqq/common/models/user.dart';
import 'package:qfqq/common/providers/meeting_agendas_provider.dart';
import 'package:qfqq/common/utils/validation.dart';
import 'package:qfqq/common/widgets/agendas/inputs/meeting_main_info_input.dart';
import 'package:qfqq/common/widgets/agendas/inputs/meeting_meta_info_input.dart';
import 'package:qfqq/common/widgets/agendas/inputs/meeting_people_input.dart';
import 'package:qfqq/common/widgets/agendas/inputs/meeting_theme_input.dart';
import 'package:qfqq/common/widgets/reusables/form_filled_button.dart';
import 'package:qfqq/common/widgets/reusables/form_outlined_button.dart';
import 'package:qfqq/generated/l10n.dart';
import 'package:qfqq/common/models/meeting_agenda.dart';

class AgendaModificationPage extends ConsumerStatefulWidget {
  final MeetingAgenda agenda;
  final bool isNewAgenda;

  AgendaModificationPage({super.key, MeetingAgenda? agendaToModify})
    : agenda = agendaToModify?.copyWith() ?? MeetingAgenda.empty(),
      isNewAgenda = agendaToModify == null;

  @override
  ConsumerState<AgendaModificationPage> createState() =>
      _AgendaModificationPageState();
}

class _AgendaModificationPageState
    extends ConsumerState<AgendaModificationPage> {
  MeetingAgendaErrors errors = MeetingAgendaErrors();
  bool isSending = false;
  late MeetingAgenda originalAgenda;

  Future<bool> shouldPop(BuildContext ctx) async {
    if (originalAgenda == widget.agenda) {
      return true;
    }
    final loc = S.of(ctx);
    return await ModalService.showConfirmation(
      ctx,
      title: loc.unsavedChangesTitle,
      message: loc.unsavedChangesMessage,
      confirmLabel: loc.unsavedChangesDiscard,
      cancelLabel: loc.unsavedChangesKeepEditing,
    );
  }

  @override
  void initState() {
    super.initState();
    originalAgenda = widget.agenda.copyWith();
    activeNavigationGuard = shouldPop;
  }

  void _updateParticipants(List<User> users) {
    widget.agenda.participantsIds = users.map((user) => user.id).toList();
    setState(() {});
  }

  @override
  void dispose() {
    activeNavigationGuard = null;
    super.dispose();
  }

  void saveAgenda(MeetingAgendaStatus status) async {
    widget.agenda.status = status;
    var meetingsError = validateMeetingAgenda(widget.agenda);
    if (meetingsError.hasAny()) {
      setState(() => errors = meetingsError);
      return;
    }

    setState(() => isSending = true);
    final service = ref.read(meetingAgendaServiceProvider);
    !widget.isNewAgenda
        ? await service.updateMeetingAgenda(widget.agenda)
        : await service.createMeetingAgenda(widget.agenda);
    setState(() => isSending = false);

    goBack();
  }

  void goBack() {
    if (!mounted) {
      return;
    }

    activeNavigationGuard = null;
    context.go(
      widget.isNewAgenda ? '/agendas' : '/agendas/${widget.agenda.id}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);
    final isEditing = !widget.isNewAgenda;

    Widget content = PrimaryScrollController(
      controller: ScrollController(),
      child: Scrollbar(
        thumbVisibility: true,
        child: SingleChildScrollView(
          primary: true,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MeetingMainInfoInput(
                      meeting: widget.agenda,
                      errors: errors,
                      onTitleChanged:
                          (value) => setState(() => widget.agenda.title = value),
                      onGoalsChanged:
                          (value) => setState(() => widget.agenda.goals = value),
                    ),

                    buildDivider(context),

                    MeetingMetaInfoInput(
                      meeting: widget.agenda,
                      errors: errors,
                      onDateSelected:
                          (value) => setState(() => widget.agenda.meetingDate = value),
                      onLocationSelected:
                          (value) => setState(() => widget.agenda.meetingLocation = value),
                      onProjectSelected:
                          (value) => setState(() => widget.agenda.projectId = value.id),
                    ),

                    buildDivider(context),

                    MeetingThemeInput(
                      meeting: widget.agenda,
                      errors: errors,
                      onThemeAdded: (theme) {
                        widget.agenda.themes.add(theme);
                        setState(() {});
                      },
                      onThemeRemoved: (theme) {
                        widget.agenda.themes.remove(theme);
                        setState(() {});
                      },
                    ),

                    buildDivider(context),

                    MeetingPeopleInput(
                      meeting: widget.agenda,
                      errors: errors,
                      onAnimatorChanged: (animator) {
                        setState(() => widget.agenda.animatorId = animator.id);
                      },
                      onParticipantsChanged: _updateParticipants
                    ),

                    const SizedBox(height: 40),

                    // Action Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        FormOutlinedButton(
                          text: loc.commonCancel,
                          onPressed: goBack,
                        ),

                        const SizedBox(width: 12),
                        FormFilledButton(
                          text:
                              isEditing
                                  ? loc.agendaPageUpdateDraft
                                  : loc.agendaPageSaveDraft,
                          isSending: isSending,
                          onPressed:
                              () => saveAgenda(MeetingAgendaStatus.draft),
                        ),

                        const SizedBox(width: 12),
                        FormFilledButton(
                          text:
                              isEditing
                                  ? loc.agendaPageUpdateAgenda
                                  : loc.agendaPageSaveAgenda,
                          isSending: isSending,
                          onPressed:
                              () => saveAgenda(MeetingAgendaStatus.planned),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    return content;
  }
}
