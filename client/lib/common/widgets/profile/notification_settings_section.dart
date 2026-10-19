import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/widgets/profile/notification_tile.dart';
import 'package:qfqq/common/providers/notification_settings_provider.dart';
import 'package:qfqq/generated/l10n.dart';

class NotificationSettingsSection extends ConsumerWidget {
  const NotificationSettingsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = S.of(context);
    final theme = Theme.of(context);
    final asyncSettings = ref.watch(notificationSettingsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.profilePageNotifications,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: theme.primaryColor,
          ),
        ),
        const SizedBox(height: 16),
        asyncSettings.when(
          loading:
              () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              ),
          error:
              (error, _) => Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer.withAlpha(60),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.colorScheme.error.withAlpha(80),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: theme.colorScheme.error,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        loc.profilePageNotificationSettingsLoadFailed,
                        style: TextStyle(
                          color: theme.colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                    IconButton.filledTonal(
                      onPressed: () {
                        ref
                            .read(notificationSettingsProvider.notifier)
                            .retry();
                      },
                      icon: const Icon(Icons.refresh),
                      tooltip: loc.commonRetry,
                    ),
                  ],
                ),
              ),
          data: (state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children:
                  state.settings.map((setting) {
                    return NotificationTile(
                      key: ValueKey(setting.type),
                      setting: setting,
                      isSavingOffset: state.isSavingOffset(setting.type),
                      isSavingActive: state.isSavingActive(setting.type),
                      onToggleActive: (isActive) async {
                        final success = await ref
                            .read(notificationSettingsProvider.notifier)
                            .updateIsActive(setting.type, isActive);

                        if (!success && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                loc.profilePageNotificationIsActiveSaveFailed,
                              ),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                      onSelectOffset: (offset) async {
                        final success = await ref
                            .read(notificationSettingsProvider.notifier)
                            .updateOffset(setting.type, offset);

                        if (!success && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                loc.profilePageNotificationOffsetSaveFailed,
                              ),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                    );
                  }).toList(),
            );
          },
        ),
      ],
    );
  }
}
