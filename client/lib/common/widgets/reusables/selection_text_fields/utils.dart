import 'package:flutter/material.dart';

defaultFieldViewBuilder(String label, String? error, IconData? icon, {double? height}) {
  return (
    BuildContext context,
    TextEditingController controller,
    FocusNode focusNode,
    VoidCallback onFieldSubmitted,
  ) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      decoration: InputDecoration(
        labelText: label,
        errorText: error,
        constraints: height != null
            ? BoxConstraints(
                minHeight: height,
                maxHeight: height,
              )
            : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        prefixIcon: icon != null ? Icon(icon) : null,
      ),
    );
  };
}

defaultOptionsViewBuilder<T>(ListTile Function(T, void Function()) itemBuilder) {
  return (
    BuildContext context,
    void Function(T) callback,
    Iterable<T> options,
  ) {
    return Align(
      alignment: Alignment.topLeft,
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(8),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 240),
          child: ListView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            itemCount: options.length,
            itemBuilder: (context, index) {
              final item = options.elementAt(index);
              return itemBuilder(item, () => callback(item));
            },
          ),
        ),
      ),
    );
  };
}
