import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/services/convex_provider.dart';
import '../../../push_notifications/services/push_notification_service.dart';

part 'settings_provider.g.dart';

class SettingsState {
  const SettingsState({
    this.sessionReminders = true,
    this.progressReminders = true,
    this.chatNotifications = true,
  });

  final bool sessionReminders;
  final bool progressReminders;
  final bool chatNotifications;

  SettingsState copyWith({
    bool? sessionReminders,
    bool? progressReminders,
    bool? chatNotifications,
  }) {
    return SettingsState(
      sessionReminders: sessionReminders ?? this.sessionReminders,
      progressReminders: progressReminders ?? this.progressReminders,
      chatNotifications: chatNotifications ?? this.chatNotifications,
    );
  }
}

@riverpod
class SettingsNotifier extends _$SettingsNotifier {
  @override
  SettingsState build() {
    _loadFromStorage();
    return const SettingsState();
  }

  Future<void> _loadFromStorage() async {
    final storage = ref.read(storageServiceProvider);
    final sessions = await storage.getNotificationPref('session_reminders');
    final progress = await storage.getNotificationPref('progress_reminders');
    final chat = await storage.getNotificationPref('chat_notifications');
    state = SettingsState(
      sessionReminders: sessions ?? true,
      progressReminders: progress ?? true,
      chatNotifications: chat ?? true,
    );
  }

  Future<void> toggleSessionReminders(bool value) async {
    state = state.copyWith(sessionReminders: value);
    final storage = ref.read(storageServiceProvider);
    await storage.saveNotificationPref('session_reminders', value);
    if (value) {
      await PushNotificationService()
          .subscribeToTopic('session_reminders');
    } else {
      await PushNotificationService()
          .unsubscribeFromTopic('session_reminders');
    }
  }

  Future<void> toggleProgressReminders(bool value) async {
    state = state.copyWith(progressReminders: value);
    final storage = ref.read(storageServiceProvider);
    await storage.saveNotificationPref('progress_reminders', value);
    if (value) {
      await PushNotificationService()
          .subscribeToTopic('progress_reminders');
    } else {
      await PushNotificationService()
          .unsubscribeFromTopic('progress_reminders');
    }
  }

  Future<void> toggleChatNotifications(bool value) async {
    state = state.copyWith(chatNotifications: value);
    final storage = ref.read(storageServiceProvider);
    await storage.saveNotificationPref('chat_notifications', value);
  }
}
