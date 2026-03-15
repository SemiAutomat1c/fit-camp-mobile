import 'package:convex_flutter/convex_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/app_user.dart';
import 'convex_service.dart';
import 'storage_service.dart';

/// Provides the [StorageService] singleton.
///
/// All consumers (auth notifier, main scaffold, etc.) should depend on this
/// rather than instantiating [StorageService] directly, so the instance can
/// be overridden in tests via [ProviderScope.overrides].
final Provider<StorageService> storageServiceProvider = Provider<StorageService>(
  (ref) => StorageService(),
  name: 'storageServiceProvider',
);

/// Provides the user's [AppUserRole] read from [storageServiceProvider].
///
/// Public counterpart to the private `_roleProvider` in `main_scaffold.dart`.
/// Defaults to [AppUserRole.member] if no role is stored yet.
final FutureProvider<AppUserRole> userRoleProvider =
    FutureProvider<AppUserRole>(
  (ref) async {
    final storage = ref.watch(storageServiceProvider);
    final stored = await storage.getRole();
    if (stored == null) return AppUserRole.member;
    return AppUserRole.fromString(stored);
  },
  name: 'userRoleProvider',
);

/// Provides the initialized [ConvexClient] singleton to the widget tree.
///
/// Requires [ConvexService.initialize] to have been called before
/// [ProviderScope] is mounted. Feature-level providers should depend on this
/// rather than calling [ConvexClient.instance] directly.
///
/// Example:
/// ```dart
/// final client = ref.watch(convexClientProvider);
/// final result = await client.query('api/myFunction', {});
/// ```
final Provider<ConvexClient> convexClientProvider = Provider<ConvexClient>(
  (ref) => ConvexService().client,
  name: 'convexClientProvider',
);
