import 'package:flutter/material.dart';
import 'package:qfqq/common/widgets/reusables/chip_list.dart';

class EmailsTextField extends StatefulWidget {
  final String? hintText;
  final ValueChanged<List<String>> onChanged;
  final String? error;

  const EmailsTextField({
    super.key,
    this.hintText,
    required this.onChanged,
    this.error,
  });

  @override
  State<EmailsTextField> createState() => EmailsTextFieldState();
}

class EmailsTextFieldState extends State<EmailsTextField> {
  final List<String> _emails = [];
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void addCurrent() {
    _addEmail(_controller.value.text);
    setState(() {
      
    });
  }

  void _addEmail(String value) {
    final email = value.trim().replaceAll(RegExp(r'[,\s\n]+'), '');
    if (email.isNotEmpty && !_emails.contains(email)) {
      setState(() {
        _emails.add(email);
      });
      widget.onChanged(_emails);
    }
    _controller.clear();
  }

  void _removeEmail(String email) {
    setState(() {
      _emails.remove(email);
    });
    widget.onChanged(_emails);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _controller,
          decoration: InputDecoration(
            hintText: widget.hintText,
            errorText: widget.error,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          onChanged: (value) {
            if (value.endsWith(' ') || value.endsWith(',') || value.endsWith('\n')) {
              _addEmail(value);
            }
          },
          onFieldSubmitted: (value) {
            _addEmail(value);
          },
        ),
        ChipList<String>(
          items: _emails,
          displayString: (email) => email,
          onDelete: _removeEmail,
        ),
      ],
    );
  }
}
