import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:qfqq/common/models/user.dart';
import 'package:qfqq/common/providers/meeting_agendas_provider.dart';
import 'package:qfqq/common/templates/page_template.dart';
import 'package:qfqq/common/utils/modals/select_date.dart';
import 'package:qfqq/common/widgets/reusables/chip_list.dart';
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
  late final TextEditingController _themeController;

  @override
  void initState() {
    super.initState();
    _themeController = TextEditingController();
  }

  Future<void> _handleDateTimeSelection() async {
    final DateTime? result = await showDateTimePicker(
      context,
      widget.agenda.reunionDate ?? DateTime.now(),
    );
    if (result == null) return;
    setState(() => widget.agenda.reunionDate = result);
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

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    String formattedDateTime = DateFormat.yMMMd(
      locale,
    ).add_Hm().format(widget.agenda.reunionDate ?? DateTime.now());
    final loc = S.of(context);
    final isEditing = !widget.isNewAgenda;

    void saveAgenda(MeetingAgendaStatus status) async {
      widget.agenda.status = status;
      final service = ref.read(meetingAgendaServiceProvider);
      if (isEditing) {
        await service.updateMeetingAgenda(widget.agenda);
      } else {
        await service.createMeetingAgenda(widget.agenda);
      }
      context.go('/agendas');
    }

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
                TextFormField(
                  initialValue: widget.agenda.title,
                  onChanged: (value) => widget.agenda.title = value,
                  decoration: InputDecoration(
                    hintText: 'Enter meeting title',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                _buildLabel(loc.agendaPageGoals),
                TextFormField(
                  initialValue: widget.agenda.reunionGoals,
                  onChanged: (value) => widget.agenda.reunionGoals = value,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'What do you want to achieve?',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
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
                            'Date & Time',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 8),
                          OutlinedButton.icon(
                            onPressed: _handleDateTimeSelection,
                            icon: const Icon(Icons.calendar_today, size: 18),
                            label: Text(formattedDateTime),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              minimumSize: const Size(double.infinity, 48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              alignment: Alignment.centerLeft,
                            ),
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
                            'Location',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            initialValue: widget.agenda.reunionLocation,
                            decoration: InputDecoration(
                              hintText: 'Room or link',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                            onChanged:
                                (value) =>
                                    widget.agenda.reunionLocation = value,
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
                          hintText: 'Add a discussion topic',
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
                      label: const Text('Add'),
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
                            'Facilitator',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 8),
                          UserTextField(
                            label: loc.agendaPageAnimatorLabel,
                            initialUserId: widget.agenda.animatorId ?? '',
                            onSelected:
                                (p0) => widget.agenda.animatorId = p0.id,
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
                            'Project',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 8),
                          ProjectTextField(
                            label: 'Select project',
                            initialProjectId: widget.agenda.projectId ?? '',
                            onSelected:
                                (project) =>
                                    widget.agenda.projectId = project.id,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                _buildLabel('Participants'),
                UsersTextField(
                  label: loc.agendaPageAddParticipant,
                  initialUsersIds: widget.agenda.participantsIds,
                  onChanged: _updateParticipants,
                ),

                const SizedBox(height: 40),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => context.go('/'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(loc.agendaPageCancel),
                    ),
                    const SizedBox(width: 12),
                    FilledButton(
                      onPressed: () => saveAgenda(MeetingAgendaStatus.draft),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        isEditing ? 'Update Agenda as draft' : 'Save Agenda as draft',
                      ),
                    ),
                    const SizedBox(width: 12),
                    FilledButton(
                      onPressed: () => saveAgenda(MeetingAgendaStatus.planned),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        isEditing ? 'Update Agenda' : loc.agendaPageSaveAgenda,
                      ),
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
