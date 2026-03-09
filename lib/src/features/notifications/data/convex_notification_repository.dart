import 'dart:convert';

import 'package:convex_flutter/convex_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/convex_provider.dart';
import '../domain/entities/app_notification.dart';
import 'notification_repository.dart';

class ConvexNotificationRepository implements NotificationRepository {
  const ConvexNotificationRepository(this._client);

  final ConvexClient _client;

  @override
  Future<List<AppNotification>> getNotifications() async {
    final raw = await _client.query('notifications:listForCurrentUser', {});
    if (raw == 'null') return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<int> getUnreadCount() async {
    final raw = await _client.query('notifications:getUnreadCount', {});
    if (raw == 'null') return 0;
    return (jsonDecode(raw) as num).toInt();
  }

  @override
  Future<void> markRead(String notificationId) async {
    await _client.mutation(
      name: 'notifications:markRead',
      args: {'notificationId': notificationId},
    );
  }

  @override
  Future<void> markAllRead() async {
    await _client.mutation(
      name: 'notifications:markAllRead',
      args: {},
    );
  }
}

final Provider<NotificationRepository> notificationRepositoryProvider =
    Provider<NotificationRepository>(
  (ref) => ConvexNotificationRepository(ref.read(convexClientProvider)),
  name: 'notificationRepositoryProvider',
);
