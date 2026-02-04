import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qfqq/common/models/errors/meeting_agenda_errors.dart';
import 'package:qfqq/common/models/user.dart';
import 'package:qfqq/common/providers/meeting_agendas_provider.dart';
import 'package:qfqq/common/templates/page_template.dart';
import 'package:qfqq/common/utils/fromatting.dart';
import 'package:qfqq/common/utils/modals/select_date.dart';
import 'package:qfqq/common/utils/validation.dart';
import 'package:qfqq/common/widgets/reusables/chip_list.dart';
import 'package:qfqq/common/widgets/reusables/form_filled_button.dart';
import 'package:qfqq/common/widgets/reusables/form_outlined_button.dart';
import 'package:qfqq/common/widgets/reusables/modification_text_field.dart';
import 'package:qfqq/common/widgets/reusables/project_text_field.dart';
import 'package:qfqq/common/widgets/reusables/user_text_field.dart';
import 'package:qfqq/common/widgets/reusables/users_text_field.dart';
import 'package:qfqq/generated/l10n.dart';
import 'package:qfqq/common/models/meeting_agenda.dart';

class AgendaModificationPage extends ConsumerStatefulWidget {
  final MeetingAgenda agenda;
  final bool isNewAgenda;

  AgendaModificationPage({super.key, MeetingAgenda? agendaToModify})
    : agenda = agendaToModify ?? MeetingAgenda.empty(),
      isNewAgenda = agendaToModify == null;

  @override
  ConsumerState<AgendaModificationPage> createState() =>
      _AgendaModificationPageState();
}

class _AgendaModificationPageState
    extends ConsumerState<AgendaModificationPage> {
  MeetingAgendaErrors errors = MeetingAgendaErrors();
  bool isSending = false;
  late final TextEditingController _themeController;

  @override
  void initState() {
    super.initState();
    _themeController = TextEditingController();
  }

  Future<void> _handleDateTimeSelection() async {
    final DateTime? result = await showDateTimePicker(
      context,
      widget.agenda.meetingDate ?? DateTime.now(),
    );
    if (result == null) return;
    setState(() => widget.agenda.meetingDate = result);
  }

  void _addTheme() {
    final theme = _themeController.text.trim();
    if (theme.isNotEmpty && !widget.agenda.themes.contains(theme)) {
      widget.agenda.themes.add(theme);
      setState(() => _themeController.clear());
    }
  }

  void _removeTheme(String theme) {
    widget.agenda.themes.remove(theme);
    setState(() {});
  }

  void _updateParticipants(List<User> users) {
    widget.agenda.participantsIds = users.map((user) => user.id).toList();
    setState(() {});
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w500,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: .7),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: Divider(
        color: Theme.of(context).colorScheme.outline.withValues(alpha: .2),
      ),
    );
  }

  @override
  void dispose() {
    _themeController.dispose();
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

    context.go(
      widget.isNewAgenda ? '/agendas' : '/agendas/${widget.agenda.id}',
    );
  }

  @override
  Widget build(BuildContext context) {
    String? formattedDateTime =
        widget.agenda.meetingDate != null
            ? formatDate(context, widget.agenda.meetingDate)
            : null;

    final loc = S.of(context);
    final isEditing = !widget.isNewAgenda;

    String title =
        isEditing
            ? '${loc.agendaPageTitleAppBar} - Update'
            : loc.agendaPageTitleAppBar;

    Widget content = SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and Goals
                _buildLabel(loc.agendaPageTitle),
                ModificationTextField(
                  initialValue: widget.agenda.title,
                  hintText: loc.agendaPageTitleHint,
                  onChanged: (value) => widget.agenda.title = value,
                  error: errors.titleError,
                ),
                const SizedBox(height: 20),

                _buildLabel(loc.agendaPageGoals),
                ModificationTextField(
                  initialValue: widget.agenda.goals ?? '',
                  hintText: loc.agendaPageGoalsHint,
                  onChanged: (value) => widget.agenda.goals = value,
                  error: errors.reunionGoalsError,
                  maxLines: 3,
                ),

                _buildDivider(),

                // Date, Time & Location in a grid
                _buildLabel(loc.agendaPageSectionScheduleLocation),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loc.agendaPageDateTime,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 8),
                          OutlinedButton.icon(
                            onPressed: _handleDateTimeSelection,
                            icon: const Icon(Icons.calendar_today, size: 18),
                            label: Text(formattedDateTime ?? ''),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              minimumSize: const Size(double.infinity, 48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              side:
                                  errors.reunionDateError != null
                                      ? BorderSide(
                                        color:
                                            Theme.of(context).colorScheme.error,
                                      )
                                      : null,
                              alignment: Alignment.centerLeft,
                            ),
                          ),
                          if (errors.reunionDateError != null)
                            SizedBox(height: 8),
                          if (errors.reunionDateError != null)
                            Row(
                              children: [
                                SizedBox(width: 16),
                                Text(
                                  errors.reunionDateError!,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loc.agendaPageLocationLabel,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 8),
                          ModificationTextField(
                            initialValue: widget.agenda.meetingLocation ?? '',
                            hintText: loc.agendaPageLocationHint,
                            onChanged:
                                (value) =>
                                    widget.agenda.meetingLocation = value,
                            error: errors.reunionLocationError,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                _buildDivider(),

                // Themes
                _buildLabel(loc.agendaPageSectionThemes),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _themeController,
                        decoration: InputDecoration(
                          hintText: loc.agendaPageThemeHint,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                        onSubmitted: (_) => _addTheme(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    FilledButton.icon(
                      onPressed: _addTheme,
                      icon: const Icon(Icons.add, size: 20),
                      label: Text(loc.agendaPageAddButton),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ChipList<String>(
                  items: widget.agenda.themes,
                  displayString: (String theme) => theme,
                  onDelete: _removeTheme,
                ),

                _buildDivider(),

                // People
                _buildLabel(loc.agendaPageSectionPeople),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loc.agendaPageFacilitator,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 8),
                          UserTextField(
                            label: loc.agendaPageAnimatorLabel,
                            initialUserId: widget.agenda.animatorId ?? '',
                            onSelected:
                                (p0) => widget.agenda.animatorId = p0.id,
                            error: errors.animatorError,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loc.agendaPageProjectLabel,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 8),
                          ProjectTextField(
                            label: loc.agendaPageSelectProject,
                            initialProjectId: widget.agenda.projectId ?? '',
                            onSelected:
                                (project) =>
                                    widget.agenda.projectId = project.id,
                            error: errors.projectError,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                _buildLabel(loc.agendaPageParticipantsLabel),
                UsersTextField(
                  label: loc.agendaPageAddParticipant,
                  initialUsersIds: widget.agenda.participantsIds,
                  onChanged: _updateParticipants,
                  error: errors.participantsError,
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
                      onPressed: () => saveAgenda(MeetingAgendaStatus.draft),
                    ),

                    const SizedBox(width: 12),
                    FormFilledButton(
                      text:
                          isEditing
                              ? loc.agendaPageUpdateAgenda
                              : loc.agendaPageSaveAgenda,
                      isSending: isSending,
                      onPressed: () => saveAgenda(MeetingAgendaStatus.planned),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );

    return buildPageTemplate(context, content, title);
  }
}
