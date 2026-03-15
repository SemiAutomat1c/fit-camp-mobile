import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Manages local notification display for foreground FCM messages.
class LocalNotificationService {
  static final LocalNotificationService _instance =
      LocalNotificationService._();
  LocalNotificationService._();
  factory LocalNotificationService() => _instance;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const _androidChannel = AndroidNotificationChannel(
    'fit_camp_default',
    '24 Fit Camp Notifications',
    description: 'General notifications from 24 Fit Camp',
    importance: Importance.high,
  );

  Future<void> initialize() async {
    const androidInit =
        AndroidInitializationSettings('@mipmap/launcher_icon');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );
    await _plugin.initialize(initSettings);

    // Create Android notification channel
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_androidChannel);
  }

  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'fit_camp_default',
      '24 Fit Camp Notifications',
      channelDescription: 'General notifications from 24 Fit Camp',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: payload,
    );
  }
}
