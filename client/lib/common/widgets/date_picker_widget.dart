import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qfqq/generated/l10n.dart';

class DatePickerWidget extends StatefulWidget {
  final DateTime? initialDate;
  final void Function(DateTime) onDateSelected;
  final String? label;

  const DatePickerWidget({
    super.key,
    this.initialDate,
    required this.onDateSelected,
    this.label,
  });

  @override
  State<DatePickerWidget> createState() => _DatePickerWidgetState();
}

class _DatePickerWidgetState extends State<DatePickerWidget> {
  DateTime? selectedDate;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedDate = widget.initialDate;
    _updateController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateController() {
    if (selectedDate != null) {
      _controller.text = DateFormat('yyyy-MM-dd').format(selectedDate!);
    } else {
      _controller.clear();
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
        _updateController();
      });
      widget.onDateSelected(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label ?? loc.commonSelectDate,
          style: Theme.of(context).textTheme.labelMedium,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _controller,
          readOnly: true,
          decoration: InputDecoration(
            hintText: loc.commonTapToSelectDate,
            suffixIcon: const Icon(Icons.calendar_today),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onTap: _selectDate,
        ),
      ],
    );
  }
}
 