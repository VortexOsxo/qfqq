import 'package:flutter/material.dart';
import 'package:qfqq/generated/l10n.dart';

class PasswordTextField extends StatefulWidget {
  final InputDecoration decoration;
  final FormFieldSetter<String>? onSaved;
  final ValueChanged<String>? onChanged;

  const PasswordTextField({
    super.key,
    required this.decoration,
    this.onSaved,
    this.onChanged,
  });

  @override
  State<PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  bool _isVisible = false;

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);

    return TextFormField(
      decoration: widget.decoration.copyWith(
        suffixIcon: IconButton(
          visualDensity: VisualDensity.compact,
          tooltip: _isVisible ? loc.hidePassword : loc.showPassword,
          icon: Icon(
            
            _isVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            size: 20,
          ),
          onPressed: () => setState(() => _isVisible = !_isVisible),
        ),
      ),
      obscureText: !_isVisible,
      onSaved: widget.onSaved,
      onChanged: widget.onChanged,
    );
  }
}