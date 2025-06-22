import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:qfqq/common/providers/current_meeting_agenda.dart';
import 'package:qfqq/common/services/meeting_agenda_service.dart';
import 'package:qfqq/common/utils/modals/select_date.dart';
import 'package:qfqq/generated/l10n.dart';
import 'package:qfqq/common/widgets/common_app_bar.dart';
import 'package:qfqq/common/models/meeting_agenda.dart';

class AgendaModificationPage extends ConsumerStatefulWidget {
  final MeetingAgenda? initialAgenda;
  const AgendaModificationPage({super.key, this.initialAgenda});

  @override
  ConsumerState<AgendaModificationPage> createState() => _AgendaModificationPageState();
}

class _AgendaModificationPageState extends ConsumerState<AgendaModificationPage> {
  late final TextEditingController _titleController;
  late final TextEditingController _goalsController;
  late final TextEditingController _locationController;
  late final TextEditingController _themeController;
  late DateTime _selectedDateTime;
  late final DateTime _redactionDate;
  late final List<String> _themes;
  late final TextEditingController _animatorController;
  late final TextEditingController _participantController;
  late final List<String> _participants;
  late MeetingAgendaStatus _status;

  @override
  void initState() {
    super.initState();
    final agenda = widget.initialAgenda;
    _titleController = TextEditingController(text: agenda?.title ?? '');
    _goalsController = TextEditingController(text: agenda?.reunionGoals ?? '');
    _locationController = TextEditingController(text: agenda?.reunionLocation ?? '');
    _themeController = TextEditingController();
    _selectedDateTime = agenda?.reunionDate ?? DateTime.now();
    _redactionDate = agenda?.redactionDate ?? DateTime.now();
    _themes = List<String>.from(agenda?.themes ?? []);
    _animatorController = TextEditingController(text: agenda?.animator ?? 'Me');
    _participantController = TextEditingController();
    _participants = List<String>.from(agenda?.participants ?? []);
    _status = agenda?.status ?? MeetingAgendaStatus.created;
  }

  Future<void> _handleDateTimeSelection() async {
    final DateTime? result = await showDateTimePicker(context, _selectedDateTime);
    if (result != null) {
      setState(() {
        _selectedDateTime = result;
      });
    }
  }

  void _addTheme() {
    final theme = _themeController.text.trim();
    if (theme.isNotEmpty && !_themes.contains(theme)) {
      setState(() {
        _themes.add(theme);
        _themeController.clear();
      });
    }
  }

  void _removeTheme(String theme) {
    setState(() {
      _themes.remove(theme);
    });
  }

  void _addParticipant() {
    final participant = _participantController.text.trim();
    if (participant.isNotEmpty && !_participants.contains(participant)) {
      setState(() {
        _participants.add(participant);
        _participantController.clear();
      });
    }
  }

  void _removeParticipant(String participant) {
    setState(() {
      _participants.remove(participant);
    });
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

  Widget _buildChipList(List<String> items, Function(String) onDelete) {
    if (items.isEmpty) return const SizedBox.shrink();
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Wrap(
        spacing: 8.0,
        runSpacing: 8.0,
        children: items.map((item) => Chip(
          label: Text(item),
          onDeleted: () => onDelete(item),
          backgroundColor: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: .3),
          deleteIconColor: Theme.of(context).colorScheme.onSurfaceVariant,
          labelStyle: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        )).toList(),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _goalsController.dispose();
    _locationController.dispose();
    _themeController.dispose();
    _animatorController.dispose();
    _participantController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    String formattedDateTime = DateFormat.yMMMd(locale).add_Hm().format(_selectedDateTime);
    String formattedRedactionDate = DateFormat.yMMMd(locale).format(_redactionDate);
    final loc = S.of(context);
    final isEditing = widget.initialAgenda != null;

    ref.watch(currentMeetingAgendaProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: CommonAppBar(title: isEditing ? loc.agendaPageTitleAppBar + ' - Update' : loc.agendaPageTitleAppBar),
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
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: loc.agendaPageTitle,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.title),
                      ),
                      onChanged: (value) => setState(() {}),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _goalsController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: loc.agendaPageGoals,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignLabelWithHint: true,
                        prefixIcon: const Padding(
                          padding: EdgeInsets.only(bottom: 60),
                          child: Icon(Icons.flag_outlined),
                        ),
                      ),
                      onChanged: (value) => setState(() {}),
                    ),
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
                    TextField(
                      controller: _locationController,
                      decoration: InputDecoration(
                        labelText: loc.agendaPageLocation,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.location_on),
                      ),
                      onChanged: (value) => setState(() {}),
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
                    _buildChipList(_themes, _removeTheme),
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
                    TextField(
                      controller: _animatorController,
                      decoration: InputDecoration(
                        labelText: loc.agendaPageAnimatorLabel,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.person),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _participantController,
                            decoration: InputDecoration(
                              labelText: loc.agendaPageAddParticipant,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              prefixIcon: const Icon(Icons.group_add),
                            ),
                            onSubmitted: (_) => _addParticipant(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        FilledButton(
                          onPressed: _addParticipant,
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
                    _buildChipList(_participants, _removeParticipant),
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
                      onPressed: _titleController.text.isNotEmpty ? () async {
                        final service = ref.read(meetingAgendaServiceProvider);
                        if (isEditing) {
                          await service.updateMeetingAgenda(
                            id: widget.initialAgenda!.id,
                            title: _titleController.text,
                            redactionDate: _redactionDate,
                            status: _status,
                            reunionGoals: _goalsController.text,
                            reunionDate: _selectedDateTime,
                            reunionLocation: _locationController.text,
                            animator: _animatorController.text,
                            participants: _participants,
                            themes: _themes,
                          );
                        } else {
                          await service.createMeetingAgenda(
                            title: _titleController.text,
                            redactionDate: _redactionDate,
                            status: _status,
                            reunionGoals: _goalsController.text,
                            reunionDate: _selectedDateTime,
                            reunionLocation: _locationController.text,
                            animator: _animatorController.text,
                            participants: _participants,
                            themes: _themes,
                          );
                        }
                        context.go('/agendas');
                      } : null,
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