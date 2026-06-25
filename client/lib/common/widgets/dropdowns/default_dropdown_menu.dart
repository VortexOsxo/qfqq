import 'package:flutter/material.dart';

class DefaultDropdownMenu<T> extends StatelessWidget {
  final List<DropdownMenuEntry<T>> entries;
  final T? initialSelection;
  final void Function(T?)? onSelected;
  final bool isDense;
  final EdgeInsetsGeometry? contentPadding;
  final BoxConstraints? constraints;
  final TextStyle? textStyle;


  const DefaultDropdownMenu({
    super.key,
    required this.entries,
    this.initialSelection,
    this.onSelected,
    this.isDense = false,
    this.contentPadding,
    this.constraints,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return DropdownMenu(
      width: 200,
      textStyle: textStyle,
      inputDecorationTheme: InputDecorationTheme(
        isDense: isDense,
        contentPadding: contentPadding,
        constraints: constraints,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: theme.primaryColor, width: 2),
        ),
      ),
      menuStyle: MenuStyle(
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      dropdownMenuEntries: entries,
      initialSelection: initialSelection,
      onSelected: onSelected,
    );
  }
}
