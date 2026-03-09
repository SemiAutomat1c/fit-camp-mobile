import '../domain/entities/app_notification.dart';

/// Abstract contract for notification data access.
abstract class NotificationRepository {
  /// Returns up to 50 notifications for the current user, newest first.
  Future<List<AppNotification>> getNotifications();

  /// Returns the count of unread notifications.
  Future<int> getUnreadCount();

  /// Marks a single notification as read.
  Future<void> markRead(String notificationId);

  /// Marks all notifications as read. Returns the count that were marked.
  Future<void> markAllRead();
}
