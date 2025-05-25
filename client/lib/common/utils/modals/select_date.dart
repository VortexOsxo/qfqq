import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

Future<DateTime?> showDateTimePicker(BuildContext context, DateTime currentDateTime) async {
  DateTime selectedDate = currentDateTime;
  final hourController = TextEditingController(text: currentDateTime.hour.toString().padLeft(2, '0'));
  final minuteController = TextEditingController(text: currentDateTime.minute.toString().padLeft(2, '0'));
  String? errorText;

  final DateTime? result = await showDialog<DateTime>(
    context: context,
    builder: (BuildContext context) {
      final loc = AppLocalizations.of(context)!;
      return Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: StatefulBuilder(
            builder: (context, setState) {
              int hour = int.tryParse(hourController.text) ?? currentDateTime.hour;
              int minute = int.tryParse(minuteController.text) ?? currentDateTime.minute;
              DateTime composedDate = DateTime(
                selectedDate.year,
                selectedDate.month,
                selectedDate.day,
                hour,
                minute,
              );
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CalendarDatePicker(
                    initialDate: selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                    onDateChanged: (DateTime date) {
                      setState(() {
                        selectedDate = DateTime(
                          date.year,
                          date.month,
                          date.day,
                          hour,
                          minute,
                        );
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.access_time),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 40,
                        child: TextField(
                          controller: hourController,
                          keyboardType: TextInputType.number,
                          maxLength: 2,
                          decoration: InputDecoration(
                            labelText: loc.selectDateHourLabel,
                            counterText: '',
                          ),
                          onChanged: (value) {
                            setState(() {
                              hour = int.tryParse(value) ?? 0;
                            });
                          },
                        ),
                      ),
                      const Text(":"),
                      SizedBox(
                        width: 40,
                        child: TextField(
                          controller: minuteController,
                          keyboardType: TextInputType.number,
                          maxLength: 2,
                          decoration: InputDecoration(
                            labelText: loc.selectDateMinuteLabel,
                            counterText: '',
                          ),
                          onChanged: (value) {
                            setState(() {
                              minute = int.tryParse(value) ?? 0;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  if (errorText != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      errorText!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Text(
                    '${loc.selectDateSelected} ${DateFormat('yyyy-MM-dd HH:mm').format(composedDate)}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(loc.selectDateCancel),
                      ),
                      TextButton(
                        onPressed: () {
                          int? hour = int.tryParse(hourController.text);
                          int? minute = int.tryParse(minuteController.text);
                          if (hour == null || hour < 0 || hour > 23 || minute == null || minute < 0 || minute > 59) {
                            setState(() {
                              errorText = loc.selectDateInvalidHourMinute;
                            });
                            return;
                          }
                          Navigator.pop(
                            context,
                            DateTime(
                              selectedDate.year,
                              selectedDate.month,
                              selectedDate.day,
                              hour,
                              minute,
                            ),
                          );
                        },
                        child: Text(loc.selectDateOk),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      );
    },
  );
  hourController.dispose();
  minuteController.dispose();
  return result;
}
