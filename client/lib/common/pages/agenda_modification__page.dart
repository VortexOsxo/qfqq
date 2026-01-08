import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:qfqq/common/models/user.dart';
import 'package:qfqq/common/providers/meeting_agendas_provider.dart';
import 'package:qfqq/common/utils/modals/select_date.dart';
import 'package:qfqq/common/widgets/reusables/chip_list.dart';
import 'package:qfqq/common/widgets/reusables/project_text_field.dart';
import 'package:qfqq/common/widgets/reusables/user_text_field.dart';
import 'package:qfqq/common/widgets/reusables/users_text_field.dart';
import 'package:qfqq/generated/l10n.dart';
import 'package:qfqq/common/widgets/common_app_bar.dart';
import 'package:qfqq/common/models/meeting_agenda.dart';

class AgendaModificationPage extends ConsumerStatefulWidget {
  final MeetingAgenda agenda;
  final bool isNewAgenda;
  
  AgendaModificationPage({super.key, MeetingAgenda? agendaToModify})
    : agenda = agendaToModify ?? MeetingAgenda.empty(),
      isNewAgenda = agendaToModify == null;

  @override
  ConsumerState<AgendaModificationPage> createState() => _AgendaModificationPageState();
}

class _AgendaModificationPageState extends ConsumerState<AgendaModificationPage> {
  late final TextEditingController _themeController;

  @override
  void initState() {
    super.initState();
    _themeController = TextEditingController();
  }

  Future<void> _handleDateTimeSelection() async {
    final DateTime? result = await showDateTimePicker(context, widget.agenda.reunionDate ?? DateTime.now());
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, top: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: .2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: child,
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
    String formattedDateTime = DateFormat.yMMMd(locale).add_Hm().format(widget.agenda.reunionDate ?? DateTime.now());
    String formattedRedactionDate = DateFormat.yMMMd(locale).format(widget.agenda.redactionDate);
    final loc = S.of(context);
    final isEditing = !widget.isNewAgenda;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: CommonAppBar(title: isEditing ? '${loc.agendaPageTitleAppBar} - Update' : loc.agendaPageTitleAppBar),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // BASIC INFO SECTION
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle(loc.agendaPageSectionMeetingDetails),
                    TextField(
                      controller: TextEditingController(text: formattedRedactionDate),
                      decoration: InputDecoration(
                        labelText: loc.agendaPageActualName,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.today),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: .3),
                      ),
                      enabled: false,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: widget.agenda.title,
                      onChanged: (value) => widget.agenda.title = value,
                      decoration: InputDecoration(
                        labelText: loc.agendaPageTitle,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.title),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: widget.agenda.reunionGoals,
                      onChanged: (value) => widget.agenda.reunionGoals = value,
                      decoration: InputDecoration(
                        labelText:  loc.agendaPageGoals,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignLabelWithHint: true,
                        prefixIcon: const Padding(
                          padding: EdgeInsets.only(bottom: 60),
                          child: Icon(Icons.flag_outlined),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              
              const SizedBox(height: 20),

              // DATE & LOCATION SECTION
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle(loc.agendaPageSectionScheduleLocation),
                    OutlinedButton.icon(
                      onPressed: _handleDateTimeSelection,
                      icon: const Icon(Icons.schedule),
                      label: Text(formattedDateTime),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: widget.agenda.reunionLocation,
                      decoration: InputDecoration(
                        labelText: loc.agendaPageLocation,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.location_on),
                      ),
                      onChanged: (value) => widget.agenda.reunionLocation = value,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // THEMES SECTION
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle(loc.agendaPageSectionThemes),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _themeController,
                            decoration: InputDecoration(
                              labelText: loc.agendaPageAddTheme,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              prefixIcon: const Icon(Icons.topic_outlined),
                            ),
                            onSubmitted: (_) => _addTheme(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        FilledButton(
                          onPressed: _addTheme,
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(52, 52),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Icon(Icons.add),
                        ),
                      ],
                    ),
                    ChipList<String>(
                      items: widget.agenda.themes,
                      displayString: (String theme) => theme,
                      onDelete: _removeTheme,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // PEOPLE SECTION
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle(loc.agendaPageSectionPeople),
                    UserTextField(
                      label: loc.agendaPageAnimatorLabel,
                      initialUserId: widget.agenda.animatorId ?? '',
                      onSelected: (p0) => widget.agenda.animatorId = p0.id,
                    ),
                    const SizedBox(height: 16),
                    UsersTextField(
                      label: loc.agendaPageAddParticipant,
                      initialUsersIds: widget.agenda.participantsIds,
                      onChanged: _updateParticipants,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Project Section
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Select Owning Project'),
                    ProjectTextField(
                      label: 'Project',
                      initialProjectId: widget.agenda.projectId ?? '',
                      onSelected:
                          (project) => widget.agenda.projectId = project.id,
                    ),
                  ],
                ),
              ),


              const SizedBox(height: 32),

              // ACTION BUTTONS
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => context.go('/'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(loc.agendaPageCancel),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: FilledButton(
                      // TODO : Add local validation and : null
                      onPressed: () async {
                        final service = ref.read(meetingAgendaServiceProvider);
                        if (isEditing) {
                          await service.updateMeetingAgenda(widget.agenda);
                        } else {
                          await service.createMeetingAgenda(widget.agenda);
                        }
                        context.go('/agendas');
                      },
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(isEditing ? 'Update' : loc.agendaPageSaveAgenda),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}