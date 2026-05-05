import 'package:flutter/material.dart';
import 'package:qfqq/common/utils/fromatting.dart';
import 'package:qfqq/common/utils/modals/select_date.dart';
import 'package:qfqq/generated/l10n.dart';

class AgendaDatePicker extends StatelessWidget {
  final DateTime? meetingDate;
  final String? meetingDateError;
  final ValueChanged<DateTime> onSelected;

  const AgendaDatePicker({
    super.key,
    required this.meetingDate,
    required this.meetingDateError,
    required this.onSelected,
  });

  Future<void> _handleDateTimeSelection(BuildContext context) async {
    final DateTime? result = await showDateTimePicker(
      context,
      meetingDate ?? DateTime.now(),
    );
    if (result == null) return;
    onSelected(result);
  }

  @override
  Widget build(BuildContext context) {
    String? formattedDateTime =
        meetingDate != null ? formatDate(context, meetingDate) : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OutlinedButton.icon(
          onPressed: () => _handleDateTimeSelection(context),
          icon: const Icon(Icons.calendar_today, size: 18),
          label: Text(
            formattedDateTime ?? S.of(context).agendaPageSelectDatePlaceholder,
          ),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            side:
                meetingDateError != null
                    ? BorderSide(color: Theme.of(context).colorScheme.error)
                    : null,
            alignment: Alignment.centerLeft,
          ),
        ),
        if (meetingDateError != null) SizedBox(height: 8),
        if (meetingDateError != null)
          Row(
            children: [
              SizedBox(width: 16),
              Text(
                meetingDateError!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
          ),
      ],
    );
  }
}
