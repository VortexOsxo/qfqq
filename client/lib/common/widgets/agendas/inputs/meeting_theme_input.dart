import 'package:flutter/material.dart';
import 'package:qfqq/common/models/errors/meeting_agenda_errors.dart';
import 'package:qfqq/common/models/meeting_agenda.dart';
import 'package:qfqq/common/templates/form_template.dart';
import 'package:qfqq/common/widgets/reusables/chip_list.dart';
import 'package:qfqq/generated/l10n.dart';

class MeetingThemeInput extends StatefulWidget {
  final MeetingAgenda meeting;
  final MeetingAgendaErrors errors;
  final ValueChanged<String> onThemeAdded;
  final ValueChanged<String> onThemeRemoved;

  const MeetingThemeInput({
    super.key,
    required this.meeting,
    required this.errors,
    required this.onThemeAdded,
    required this.onThemeRemoved,
  });

  @override
  State<StatefulWidget> createState() {
    return _MeetingThemeInputState();
  }
}

class _MeetingThemeInputState extends State<MeetingThemeInput> {
  late final TextEditingController _themeController;

  @override
  void initState() {
    super.initState();
    _themeController = TextEditingController();
  }

  @override
  void dispose() {
    _themeController.dispose();
    super.dispose();
  }

  void _addTheme() {
    final theme = _themeController.text.trim();
    if (theme.isNotEmpty && !widget.meeting.themes.contains(theme)) {
      widget.onThemeAdded(theme);
      setState(() => _themeController.clear());
    }
  }

  void _removeTheme(String theme) {
    widget.onThemeRemoved(theme);
  }

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        buildLabel(context, loc.agendaPageSectionThemes),
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
            SizedBox(
              height: 48,
              child: FilledButton.icon(
                onPressed: _addTheme,
                icon: const Icon(Icons.add, size: 20),
                label: Text(loc.agendaPageAddButton),
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ChipList<String>(
          items: widget.meeting.themes,
          displayString: (String theme) => theme,
          onDelete: _removeTheme,
        ),
      ],
    );
  }
}
