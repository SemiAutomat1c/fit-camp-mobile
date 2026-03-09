import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/convex_notification_repository.dart';
import '../../domain/entities/app_notification.dart';

part 'notification_provider.g.dart';

/// Manages the full list of notifications with optimistic read-state updates.
///
/// Call [markRead] or [markAllRead] to mutate remotely and update state
/// without a full refetch.
@riverpod
class NotificationsNotifier extends _$NotificationsNotifier {
  @override
  Future<List<AppNotification>> build() async {
    final repo = ref.watch(notificationRepositoryProvider);
    return repo.getNotifications();
  }

  /// Marks a single notification as read in both the backend and local state.
  ///
  /// Applies the optimistic update immediately before the network call so the
  /// UI responds without waiting for a round-trip.
  Future<void> markRead(String id) async {
    // Apply optimistic update first so the UI responds immediately.
    final current = state.valueOrNull;
    if (current != null) {
      state = AsyncData(
        current.map((n) => n.id == id ? n.copyWithRead() : n).toList(),
      );
    }

    try {
      final repo = ref.read(notificationRepositoryProvider);
      await repo.markRead(id);
    } catch (_) {
      // On failure, restore the previous state so the item re-appears unread.
      if (current != null) state = AsyncData(current);
    }
  }

  /// Marks all notifications as read in both the backend and local state.
  ///
  /// Applies the optimistic update immediately before the network call.
  Future<void> markAllRead() async {
    // Apply optimistic update first.
    final current = state.valueOrNull;
    if (current != null) {
      state = AsyncData(current.map((n) => n.copyWithRead()).toList());
    }

    try {
      final repo = ref.read(notificationRepositoryProvider);
      await repo.markAllRead();
    } catch (_) {
      // On failure, restore the previous state.
      if (current != null) state = AsyncData(current);
    }
  }
}

/// Provides the count of unread notifications used by [NotificationBell].
///
/// Derived from the local [NotificationsNotifier] list so the badge updates
/// immediately on optimistic mark-read without a separate network round-trip.
@riverpod
int unreadNotificationCount(Ref ref) {
  final listAsync = ref.watch(notificationsNotifierProvider);
  return listAsync.valueOrNull?.where((n) => !n.read).length ?? 0;
}
