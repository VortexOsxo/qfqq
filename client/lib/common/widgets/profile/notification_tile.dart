import 'package:flutter/material.dart';
import 'package:qfqq/common/providers/notification_settings_provider.dart';
import 'package:qfqq/common/services/notification_settings_service.dart';
import 'package:qfqq/generated/l10n.dart';

class NotificationTile extends StatelessWidget {
  final NotificationOffset setting;
  final bool isSavingOffset;
  final bool isSavingActive;
  final ValueChanged<bool> onToggleActive;
  final ValueChanged<Duration> onSelectOffset;

  const NotificationTile({
    super.key,
    required this.setting,
    required this.isSavingOffset,
    required this.isSavingActive,
    required this.onToggleActive,
    required this.onSelectOffset,
  });

  static String formatOffset(S loc, Duration offset) {
    return switch (offset.inSeconds) {
      0 => loc.profilePageNotificationOffsetImmediate,
      300 => loc.profilePageNotificationOffsetFiveMinutes,
      900 => loc.profilePageNotificationOffsetFifteenMinutes,
      1800 => loc.profilePageNotificationOffsetThirtyMinutes,
      3600 => loc.profilePageNotificationOffsetOneHour,
      7200 => loc.profilePageNotificationOffsetTwoHours,
      86400 => loc.profilePageNotificationOffsetOneDay,
      _ => loc.profilePageNotificationOffsetCustom(offset.inMinutes),
    };
  }

  static String getTitle(S loc, NotificationType type) {
    return switch (type) {
      NotificationType.meetingStart => loc.profilePageNotificationMeetingStart,
      NotificationType.decisionDue => loc.profilePageNotificationDecisionDue,
      NotificationType.meetingStarted =>
        loc.profilePageNotificationMeetingStarted,
    };
  }

  static String getSubtitle(S loc, NotificationType type) {
    return switch (type) {
      NotificationType.meetingStart =>
        loc.profilePageNotificationMeetingStartSubtitle,
      NotificationType.decisionDue =>
        loc.profilePageNotificationDecisionDueSubtitle,
      NotificationType.meetingStarted =>
        loc.profilePageNotificationMeetingStartedSubtitle,
    };
  }

  static String getSwitchTooltip(S loc, bool isActive) {
    return isActive
        ? loc.profilePageNotificationSilenceTooltip
        : loc.profilePageNotificationEnableTooltip;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = S.of(context);
    final isSaving = isSavingOffset || isSavingActive;

    // Collect offset options, ensuring current offset is present if custom
    final options = [...NotificationSettingsNotifier.defaultOffsetOptions];
    if (!options.contains(setting.offset)) {
      options.insert(0, setting.offset);
    }

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withAlpha(120),
        ),
      ),
      color: theme.colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Title on the left with subtitle in tooltip
            Expanded(
              child: Tooltip(
                message: getSubtitle(loc, setting.type),
                waitDuration: const Duration(milliseconds: 300),
                child: Text(
                  getTitle(loc, setting.type),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Offset dropdown pill, smoothly animated when active
            ClipRect(
              child: AnimatedSize(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                child:
                    setting.isActive
                        ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildOffsetPill(
                              theme,
                              loc,
                              options,
                              isSaving,
                            ),
                            const SizedBox(width: 8),
                          ],
                        )
                        : const SizedBox.shrink(),
              ),
            ),

            // Toggle switch
            if (isSavingActive)
              const SizedBox(
                width: 28,
                height: 28,
                child: Padding(
                  padding: EdgeInsets.all(4),
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            else
              Tooltip(
                message: getSwitchTooltip(loc, setting.isActive),
                waitDuration: const Duration(milliseconds: 150),
                child: Switch(
                  value: setting.isActive,
                  onChanged:
                      isSaving ? null : (active) => onToggleActive(active),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOffsetPill(
    ThemeData theme,
    S loc,
    List<Duration> options,
    bool isSaving,
  ) {
    return PopupMenuButton<Duration>(
      tooltip: '',
      enabled: !isSaving,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withAlpha(100),
        ),
      ),
      onSelected: (duration) {
        if (duration != setting.offset) {
          onSelectOffset(duration);
        }
      },
      itemBuilder: (context) {
        return options.map((duration) {
          final isSelected = duration == setting.offset;
          return PopupMenuItem<Duration>(
            value: duration,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    formatOffset(loc, duration),
                    style: TextStyle(
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                      color:
                          isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_rounded,
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),
              ],
            ),
          );
        }).toList();
      },
      child: Container(
        constraints: const BoxConstraints(minWidth: 135),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withAlpha(120),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withAlpha(150),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              formatOffset(loc, setting.offset),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 6),
            if (isSavingOffset)
              const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              Icon(
                Icons.arrow_drop_down_rounded,
                size: 20,
                color: theme.colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }
}
