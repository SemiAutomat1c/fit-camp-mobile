import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/services/convex_provider.dart';
import '../services/push_notification_service.dart';

part 'push_provider.g.dart';

@riverpod
class PushNotificationNotifier extends _$PushNotificationNotifier {
  @override
  Future<void> build() async {
    final service = PushNotificationService();
    await service.initialize();

    // Save FCM token to Convex if we have one
    final token = service.fcmToken;
    if (token != null) {
      await _saveToken(token);
    }
  }

  Future<void> _saveToken(String token) async {
    try {
      final client = ref.read(convexClientProvider);
      await client.mutation(
        name: 'users:saveFcmToken',
        args: {'token': token},
      );
    } catch (_) {
      // Non-fatal: token will be saved on next app open
    }
  }

  Future<bool> requestPermission() async {
    return PushNotificationService().requestPermission();
  }

  Future<void> updateBadgeCount(int count) async {
    try {
      if (count > 0) {
        await FlutterAppBadger.updateBadgeCount(count);
      } else {
        await FlutterAppBadger.removeBadge();
      }
    } catch (_) {}
  }
}
