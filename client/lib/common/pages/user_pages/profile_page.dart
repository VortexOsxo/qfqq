import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/models/states/auth_state.dart';
import 'package:qfqq/common/services/auth_service.dart';
import 'package:qfqq/generated/l10n.dart';
import 'package:qfqq/common/providers/locale_provider.dart';
import 'package:qfqq/common/services/notification_settings_service.dart';
import 'package:qfqq/common/widgets/dropdowns/default_dropdown_menu.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    if (!authState.isAuthenticated) {
      return SizedBox.shrink(); // TODO: Had an explaition message and allow to 'disconnect' and go to login page
    }

    return _buildTopBar(context, ref, authState);
  }

  Widget _buildTopBar(
    BuildContext context,
    WidgetRef ref,
    AuthState authState,
  ) {
    final loc = S.of(context);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loc.commonProfile,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    Text(
                      authState.user?.displayName ?? '',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 20,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    Text(
                      authState.user?.email ?? '',
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 18,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(child: _NotificationSettings()),
                const SizedBox(width: 32),
                Expanded(child: _buildLanguageSelector(context, ref, loc)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSelector(BuildContext context, WidgetRef ref, S loc) {
    final currentLocale = ref.watch(localeProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.profilePageLanguage,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        DefaultDropdownMenu<Locale>(
          initialSelection: currentLocale,
          entries: const [
            DropdownMenuEntry(value: Locale('en'), label: 'English'),
            DropdownMenuEntry(value: Locale('fr'), label: 'Français'),
          ],
          onSelected: (newLocale) {
            if (newLocale != null) {
              ref.read(localeProvider.notifier).setLocale(newLocale);
            }
          },
        ),
      ],
    );
  }
}

class _NotificationSettings extends ConsumerStatefulWidget {
  const _NotificationSettings();

  @override
  ConsumerState<_NotificationSettings> createState() =>
      _NotificationSettingsState();
}

class _NotificationSettingsState extends ConsumerState<_NotificationSettings> {
  static const _configurableNotificationTypes = [
    NotificationType.meetingStart,
    NotificationType.decisionDue,
  ];

  static const _offsetOptions = [
    Duration.zero,
    Duration(minutes: 5),
    Duration(minutes: 15),
    Duration(minutes: 30),
    Duration(hours: 1),
    Duration(hours: 2),
    Duration(days: 1),
  ];

  late Future<List<NotificationOffset>> _offsetsFuture;
  final Map<NotificationType, Duration> _selectedOffsets = {};
  final Set<NotificationType> _saving = {};

  @override
  void initState() {
    super.initState();
    _offsetsFuture =
        ref.read(notificationSettingsServiceProvider).getNotificationOffsets();
  }

  Future<void> _saveOffset(NotificationType type, Duration offset) async {
    setState(() => _saving.add(type));
    try {
      final saved = await ref
          .read(notificationSettingsServiceProvider)
          .updateNotificationOffset(type, offset);

      if (!mounted) return;
      if (saved) {
        setState(() => _selectedOffsets[type] = offset);
      } else {
        _showSaveError();
      }
    } on Exception {
      if (mounted) _showSaveError();
    } finally {
      if (mounted) setState(() => _saving.remove(type));
    }
  }

  void _showSaveError() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(S.of(context).profilePageNotificationOffsetSaveFailed),
      ),
    );
  }

  void _retryLoading() {
    setState(() {
      _offsetsFuture =
          ref
              .read(notificationSettingsServiceProvider)
              .getNotificationOffsets();
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.profilePageNotifications,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        FutureBuilder<List<NotificationOffset>>(
          future: _offsetsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Row(
                children: [
                  Expanded(
                    child: Text(loc.profilePageNotificationSettingsLoadFailed),
                  ),
                  IconButton(
                    onPressed: _retryLoading,
                    icon: const Icon(Icons.refresh),
                    tooltip: loc.commonRetry,
                  ),
                ],
              );
            }

            final offsets = snapshot.data!;
            return Column(
              children:
                  _configurableNotificationTypes
                      .map(
                        (type) =>
                            _buildOffsetSelector(context, loc, type, offsets),
                      )
                      .toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildOffsetSelector(
    BuildContext context,
    S loc,
    NotificationType type,
    List<NotificationOffset> offsets,
  ) {
    final typeOffsets = offsets.where((item) => item.type == type);
    final savedOffset = typeOffsets.isEmpty ? null : typeOffsets.first.offset;
    final selectedOffset = _selectedOffsets[type] ?? savedOffset;
    final options = [..._offsetOptions];
    if (selectedOffset != null && !options.contains(selectedOffset)) {
      options.insert(0, selectedOffset);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _notificationTypeLabel(loc, type),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          DefaultDropdownMenu<Duration>(
            initialSelection: selectedOffset,
            entries:
                options
                    .map(
                      (offset) => DropdownMenuEntry(
                        value: offset,
                        label: _offsetLabel(loc, offset),
                      ),
                    )
                    .toList(),
            onSelected:
                _saving.contains(type)
                    ? null
                    : (offset) {
                      if (offset != null && offset != selectedOffset) {
                        _saveOffset(type, offset);
                      }
                    },
          ),
          if (_saving.contains(type))
            const LinearProgressIndicator(minHeight: 2),
        ],
      ),
    );
  }

  String _notificationTypeLabel(S loc, NotificationType type) {
    return switch (type) {
      NotificationType.meetingStart => loc.profilePageNotificationMeetingStart,
      NotificationType.decisionDue => loc.profilePageNotificationDecisionDue,
      NotificationType.meetingStarted =>
        loc.profilePageNotificationMeetingStarted,
    };
  }

  String _offsetLabel(S loc, Duration offset) {
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
}
