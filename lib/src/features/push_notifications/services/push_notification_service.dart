import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'local_notification_service.dart';

/// Manages Firebase Cloud Messaging initialization, permissions, and token.
class PushNotificationService {
  static final PushNotificationService _instance =
      PushNotificationService._();
  PushNotificationService._();
  factory PushNotificationService() => _instance;

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  String? _fcmToken;

  String? get fcmToken => _fcmToken;

  Future<void> initialize() async {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Get initial token
    try {
      _fcmToken = await _messaging.getToken();
    } catch (e) {
      if (kDebugMode) print('FCM token error: $e');
    }

    // Listen for token refresh
    _messaging.onTokenRefresh.listen((token) {
      _fcmToken = token;
    });
  }

  Future<bool> requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
    } catch (e) {
      if (kDebugMode) print('Subscribe error: $e');
    }
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
    } catch (e) {
      if (kDebugMode) print('Unsubscribe error: $e');
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification != null) {
      LocalNotificationService().showNotification(
        title: notification.title ?? 'Notification',
        body: notification.body ?? '',
        payload: message.data['route'] as String?,
      );
    }
  }
}

/// Top-level handler for background messages (must be top-level function).
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Background messages are handled by the system notification tray.
  if (kDebugMode) print('Background message: ${message.messageId}');
}
