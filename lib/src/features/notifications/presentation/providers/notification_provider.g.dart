// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$unreadNotificationCountHash() =>
    r'ecc641b90bd145fac003c38e88b19538381373f3';

/// Provides the count of unread notifications used by [NotificationBell].
///
/// Derived from the local [NotificationsNotifier] list so the badge updates
/// immediately on optimistic mark-read without a separate network round-trip.
///
/// Copied from [unreadNotificationCount].
@ProviderFor(unreadNotificationCount)
final unreadNotificationCountProvider = AutoDisposeProvider<int>.internal(
  unreadNotificationCount,
  name: r'unreadNotificationCountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$unreadNotificationCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UnreadNotificationCountRef = AutoDisposeProviderRef<int>;
String _$notificationsNotifierHash() =>
    r'55861ae063d4690bba9cb049da3d7de6bce9d2d0';

/// Manages the full list of notifications with optimistic read-state updates.
///
/// Call [markRead] or [markAllRead] to mutate remotely and update state
/// without a full refetch.
///
/// Copied from [NotificationsNotifier].
@ProviderFor(NotificationsNotifier)
final notificationsNotifierProvider =
    AutoDisposeAsyncNotifierProvider<
      NotificationsNotifier,
      List<AppNotification>
    >.internal(
      NotificationsNotifier.new,
      name: r'notificationsNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$notificationsNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$NotificationsNotifier =
    AutoDisposeAsyncNotifier<List<AppNotification>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
