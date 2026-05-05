import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/models/errors/meeting_agenda_errors.dart';
import 'package:qfqq/common/models/meeting_agenda.dart';
import 'package:qfqq/common/models/user.dart';
import 'package:qfqq/common/providers/meeting_agendas_provider.dart';
import 'package:qfqq/common/templates/form_template.dart';
import 'package:qfqq/common/utils/validation.dart';
import 'package:qfqq/common/widgets/agendas/inputs/meeting_main_info_input.dart';
import 'package:qfqq/common/widgets/agendas/inputs/meeting_meta_info_input.dart';
import 'package:qfqq/common/widgets/agendas/inputs/meeting_people_input.dart';
import 'package:qfqq/common/widgets/agendas/inputs/meeting_theme_input.dart';
import 'package:qfqq/common/widgets/reusables/form_filled_button.dart';
import 'package:qfqq/common/widgets/reusables/form_outlined_button.dart';
import 'package:qfqq/generated/l10n.dart';

class AgendaNextCreation extends ConsumerStatefulWidget {
  final MeetingAgenda agenda;

  const AgendaNextCreation({super.key, required this.agenda});

  @override
  ConsumerState<AgendaNextCreation> createState() => _AgendaNextCreationState();
}

class _AgendaNextCreationState extends ConsumerState<AgendaNextCreation> {
  final ScrollController _scrollController = ScrollController();
  MeetingAgendaErrors errors = MeetingAgendaErrors();
  bool isSending = false;

  void _updateParticipants(List<User> users) {
    widget.agenda.participantsIds = users.map((user) => user.id).toList();
    setState(() {});
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
    await service.createMeetingAgenda(widget.agenda);
    if (!mounted) return;

    setState(() => isSending = false);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);

    final content = Scrollbar(
      controller: _scrollController,
      thumbVisibility: true,
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: MeetingMainInfoInput(
                          meeting: widget.agenda,
                          errors: errors,
                          onTitleChanged:
                              (value) =>
                                  setState(() => widget.agenda.title = value),
                          onGoalsChanged:
                              (value) =>
                                  setState(() => widget.agenda.goals = value),
                        ),
                      ),
                      SizedBox(width: 32),

                      Expanded(
                        flex: 1,
                        child: MeetingMetaInfoInput(
                          meeting: widget.agenda,
                          errors: errors,
                          onDateSelected:
                              (value) => setState(
                                () => widget.agenda.meetingDate = value,
                              ),
                          onLocationSelected:
                              (value) => setState(
                                () => widget.agenda.meetingLocation = value,
                              ),
                          onProjectSelected:
                              (value) => setState(
                                () => widget.agenda.projectId = value.id,
                              ),
                        ),
                      ),
                    ],
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
                    onParticipantsChanged: _updateParticipants,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    return AlertDialog(
      title: Text(loc.agendaNextCreation),
      content: content,
      actions: [
        FormOutlinedButton(
          text: loc.commonCancel,
          onPressed: () => Navigator.pop(context),
        ),

        const SizedBox(width: 12),
        FormFilledButton(
          text: loc.agendaNextCreationPlan,
          isSending: isSending,
          onPressed: () => saveAgenda(MeetingAgendaStatus.planned),
        ),
      ],
    );
  }
}
