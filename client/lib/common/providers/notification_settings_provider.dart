import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/services/notification_settings_service.dart';

class NotificationSettingsState {
  final List<NotificationOffset> settings;
  final Set<NotificationType> savingOffsetTypes;
  final Set<NotificationType> savingActiveTypes;

  const NotificationSettingsState({
    this.settings = const [],
    this.savingOffsetTypes = const {},
    this.savingActiveTypes = const {},
  });

  bool isSavingOffset(NotificationType type) => savingOffsetTypes.contains(type);
  bool isSavingActive(NotificationType type) => savingActiveTypes.contains(type);

  NotificationSettingsState copyWith({
    List<NotificationOffset>? settings,
    Set<NotificationType>? savingOffsetTypes,
    Set<NotificationType>? savingActiveTypes,
  }) {
    return NotificationSettingsState(
      settings: settings ?? this.settings,
      savingOffsetTypes: savingOffsetTypes ?? this.savingOffsetTypes,
      savingActiveTypes: savingActiveTypes ?? this.savingActiveTypes,
    );
  }
}

class NotificationSettingsNotifier
    extends AsyncNotifier<NotificationSettingsState> {
  static const List<NotificationType> configurableTypes = [
    NotificationType.meetingStart,
    NotificationType.decisionDue,
  ];

  static const List<Duration> defaultOffsetOptions = [
    Duration.zero,
    Duration(minutes: 5),
    Duration(minutes: 15),
    Duration(minutes: 30),
    Duration(hours: 1),
    Duration(hours: 2),
    Duration(days: 1),
  ];

  @override
  Future<NotificationSettingsState> build() async {
    final service = ref.watch(notificationSettingsServiceProvider);
    final offsets = await service.getNotificationOffsets();

    final settings = configurableTypes.map((type) {
      final existing = offsets.where((item) => item.type == type).firstOrNull;
      return existing ??
          NotificationOffset(
            type: type,
            offset: const Duration(minutes: 15),
            isActive: true,
          );
    }).toList();

    return NotificationSettingsState(settings: settings);
  }

  Future<bool> updateOffset(NotificationType type, Duration offset) async {
    final current = state.valueOrNull;
    if (current == null) return false;

    state = AsyncData(
      current.copyWith(savingOffsetTypes: {...current.savingOffsetTypes, type}),
    );

    var success = false;
    try {
      final service = ref.read(notificationSettingsServiceProvider);
      success = await service.updateNotificationOffset(type, offset);
      return success;
    } catch (_) {
      return false;
    } finally {
      final latest = state.valueOrNull;
      if (latest != null) {
        final updatedSettings = success
            ? latest.settings
                .map((s) => s.type == type ? s.copyWith(offset: offset, isActive: true) : s)
                .toList()
            : latest.settings;
        state = AsyncData(
          latest.copyWith(
            settings: updatedSettings,
            savingOffsetTypes: {...latest.savingOffsetTypes}..remove(type),
          ),
        );
      }
    }
  }

  Future<bool> updateIsActive(NotificationType type, bool isActive) async {
    final current = state.valueOrNull;
    if (current == null) return false;

    state = AsyncData(
      current.copyWith(savingActiveTypes: {...current.savingActiveTypes, type}),
    );

    var success = false;
    try {
      final service = ref.read(notificationSettingsServiceProvider);
      success = await service.updateNotificationIsActive(type, isActive);
      return success;
    } catch (_) {
      return false;
    } finally {
      final latest = state.valueOrNull;
      if (latest != null) {
        final updatedSettings = success
            ? latest.settings
                .map((s) => s.type == type ? s.copyWith(isActive: isActive) : s)
                .toList()
            : latest.settings;
        state = AsyncData(
          latest.copyWith(
            settings: updatedSettings,
            savingActiveTypes: {...latest.savingActiveTypes}..remove(type),
          ),
        );
      }
    }
  }

  void retry() {
    ref.invalidateSelf();
  }
}

final notificationSettingsProvider = AsyncNotifierProvider<
  NotificationSettingsNotifier,
  NotificationSettingsState
>(NotificationSettingsNotifier.new);
