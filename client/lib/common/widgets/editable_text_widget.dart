import 'package:flutter/material.dart';

class EditableTextWidget extends StatefulWidget {
  final String initialValue;
  final ValueChanged<String> onSave;

  const EditableTextWidget({
    Key? key,
    required this.initialValue,
    required this.onSave,
  }) : super(key: key);

  @override
  State<EditableTextWidget> createState() => _EditableTextWidgetState();
}

class _EditableTextWidgetState extends State<EditableTextWidget> {
  late String _currentValue;
  bool _isEditing = false;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.initialValue;
    _controller = TextEditingController(text: _currentValue);
  }

  void _startEditing() {
    setState(() {
      _isEditing = true;
    });
  }

  void _cancelEditing() {
    setState(() {
      _controller.text = _currentValue;
      _isEditing = false;
    });
  }

  void _saveEditing() {
    setState(() {
      _currentValue = _controller.text;
      widget.onSave(_currentValue);
      _isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isEditing
        ? Row(
          children: [
            Expanded(
              child: TextField(controller: _controller, autofocus: true),
            ),
            IconButton(
              icon: Icon(Icons.check, color: Colors.green),
              onPressed: _saveEditing,
            ),
            IconButton(
              icon: Icon(Icons.close, color: Colors.red),
              onPressed: _cancelEditing,
            ),
          ],
        )
        : Row(
          children: [
            Expanded(
              child: Text(_currentValue, style: TextStyle(fontSize: 16)),
            ),
            IconButton(icon: Icon(Icons.edit), onPressed: _startEditing),
          ],
        );
  }
}
