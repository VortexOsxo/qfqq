import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/providers/sidebar_provider.dart';
import 'package:qfqq/common/widgets/common_app_bar.dart';
import 'package:qfqq/desktop/widgets/sidebar_widget.dart';
import 'package:qfqq/generated/l10n.dart';

class DefaultPageScaffold extends ConsumerWidget {
  final Widget child;
  final String? title;

  const DefaultPageScaffold({
    super.key,
    required this.child,
    this.title,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSidebarVisible = ref.watch(sidebarProvider);
    final theme = Theme.of(context);
    final pageTitle = title ?? "QFQQ";

    return Scaffold(
      backgroundColor: theme.colorScheme.primary,
      appBar: CommonAppBar(title: pageTitle),
      body: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            width: isSidebarVisible ? 250 : 0,
            child: const ClipRect(
              child: OverflowBox(
                minWidth: 250,
                maxWidth: 250,
                alignment: Alignment.topLeft,
                child: SidebarWidget(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: _VerticalSidebarToggleButton(
              isSidebarVisible: isSidebarVisible,
              onToggle: () => ref.read(sidebarProvider.notifier).toggle(),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.fromLTRB(2, 4, 4, 4),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: child,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VerticalSidebarToggleButton extends StatefulWidget {
  final bool isSidebarVisible;
  final VoidCallback onToggle;

  const _VerticalSidebarToggleButton({
    required this.isSidebarVisible,
    required this.onToggle,
  });

  @override
  State<_VerticalSidebarToggleButton> createState() =>
      _VerticalSidebarToggleButtonState();
}

class _VerticalSidebarToggleButtonState
    extends State<_VerticalSidebarToggleButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = S.of(context);
    final tooltipMessage = widget.isSidebarVisible
        ? loc.commonHideSidebar
        : loc.commonShowSidebar;

    return Center(
      child: Tooltip(
        message: tooltipMessage,
        child: MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: widget.onToggle,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 18,
              height: 64,
              decoration: BoxDecoration(
                color: _isHovered
                    ? theme.colorScheme.onPrimary.withValues(alpha: 0.35)
                    : theme.colorScheme.onPrimary.withValues(alpha: 0.20),
                borderRadius: BorderRadius.circular(9),
                border: Border.all(
                  color: _isHovered
                      ? theme.colorScheme.onPrimary.withValues(alpha: 0.60)
                      : theme.colorScheme.onPrimary.withValues(alpha: 0.30),
                  width: 1,
                ),
                boxShadow: _isHovered
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Icon(
                  widget.isSidebarVisible
                      ? Icons.chevron_left
                      : Icons.chevron_right,
                  size: 16,
                  color: theme.colorScheme.onPrimary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Widget defaultPageScaffold(BuildContext context, Widget child, {String? title}) {
  return DefaultPageScaffold(title: title, child: child);
}
