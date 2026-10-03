import 'package:flutter/material.dart';

class HoverTextButton extends StatefulWidget {
  final String text;
  final VoidCallback onTap;
  final bool isActive;
  final TextStyle Function(BuildContext, bool, bool)? getTextStyle;
  final Color? color;
  final Color? activeColor;
  final Color? hoverColor;
  final double fontSize;
  final FontWeight fontWeight;
  final FontWeight activeFontWeight;
  final FontWeight hoverFontWeight;
  final EdgeInsetsGeometry padding;
  final IconData? activeIcon;
  final double iconSize;
  final double iconWidth;
  final double spacing;

  const HoverTextButton({
    required this.text,
    required this.onTap,
    this.isActive = false,
    this.getTextStyle,
    this.color,
    this.activeColor,
    this.hoverColor,
    this.fontSize = 18,
    this.fontWeight = FontWeight.normal,
    this.activeFontWeight = FontWeight.bold,
    this.hoverFontWeight = FontWeight.bold,
    this.padding = const EdgeInsets.all(8),
    this.activeIcon = Icons.arrow_right,
    this.iconSize = 20,
    this.iconWidth = 16,
    this.spacing = 4,
    super.key,
  });

  @override
  State<HoverTextButton> createState() => _HoverTextButtonState();
}

class _HoverTextButtonState extends State<HoverTextButton> {
  bool _hovering = false;

  Color _getColor(BuildContext context, {bool includeHover = true}) {
    final colorScheme = Theme.of(context).colorScheme;
    if (widget.isActive) {
      return widget.activeColor ?? widget.color ?? colorScheme.onPrimary;
    }
    if (includeHover && _hovering) {
      return widget.hoverColor ?? widget.color ?? colorScheme.onPrimary;
    }
    return widget.color ?? colorScheme.onPrimary;
  }

  TextStyle _getTextStyle(BuildContext context) {
    final customStyle = widget.getTextStyle;
    if (customStyle != null)
      return customStyle(context, widget.isActive, _hovering);

    return TextStyle(
      color: _getColor(context),
      fontSize: widget.fontSize,
      fontWeight:
          widget.isActive
              ? widget.activeFontWeight
              : _hovering
              ? widget.hoverFontWeight
              : widget.fontWeight,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final padding = widget.padding.resolve(Directionality.of(context));
        final maxTextWidth =
            constraints.maxWidth.isFinite
                ? (constraints.maxWidth -
                        padding.horizontal -
                        widget.iconWidth -
                        widget.spacing)
                    .clamp(0.0, constraints.maxWidth)
                    .toDouble()
                : double.infinity;

        return Padding(
          padding: widget.padding,
          child: MouseRegion(
            onEnter: (_) => setState(() => _hovering = true),
            onExit: (_) => setState(() => _hovering = false),
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: widget.onTap,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: widget.iconWidth,
                    child:
                        widget.isActive && widget.activeIcon != null
                            ? Icon(
                              widget.activeIcon,
                              color: _getColor(context, includeHover: false),
                              size: widget.iconSize,
                            )
                            : null,
                  ),
                  SizedBox(width: widget.spacing),
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxTextWidth),
                    child: Text(
                      widget.text,
                      softWrap: true,
                      style: _getTextStyle(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
