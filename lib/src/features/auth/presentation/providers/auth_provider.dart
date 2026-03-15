import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/models/app_user.dart';
import '../../../../core/services/convex_provider.dart';
import '../../../../core/services/crashlytics_service.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../shared/router/app_router.dart';
import '../../data/convex_auth_repository.dart';

part 'auth_provider.g.dart';

/// Manages the current authenticated user's state across the app lifecycle.
///
/// State: [AsyncValue<AppUser?>]
/// - `data(null)` — initial / signed out
/// - `loading()` — sign-in or token check in progress
/// - `data(user)` — authenticated
/// - `error(msg, st)` — last auth operation failed
///
/// Use [authNotifierProvider] to watch state and call methods.
@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  AsyncValue<AppUser?> build() => const AsyncValue.data(null);

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Restores a persisted session from [StorageService].
  ///
  /// Called from the splash screen. Updates [appInitProvider] on completion.
  Future<void> checkAuth() async {
    final storage = ref.read(storageServiceProvider);
    final token = await storage.getToken();

    if (token == null) {
      ref.read(appInitProvider.notifier).state = AppInitState.unauthenticated;
      return;
    }

    try {
      // Restore the JWT on the Convex client so queries are authenticated.
      // Skip on web due to convex_flutter WebSocket protocol bug.
      if (!kIsWeb) {
        final client = ref.read(convexClientProvider);
        await client.setAuth(token: token);
      }

      final repo = ref.read(authRepositoryProvider);
      final user = await repo.getCurrentUser();

      if (user == null) {
        await storage.deleteAll();
        ref.read(appInitProvider.notifier).state = AppInitState.unauthenticated;
        return;
      }

      state = AsyncValue.data(user);

      final onboardingDone = await storage.getOnboardingComplete(user.id);
      if (onboardingDone != true) {
        ref.read(appInitProvider.notifier).state = AppInitState.needsOnboarding;
      } else {
        ref.read(appInitProvider.notifier).state = AppInitState.ready;
      }
    } catch (_) {
      await storage.deleteAll();
      ref.read(appInitProvider.notifier).state = AppInitState.unauthenticated;
    }
  }

  /// Signs in with email + password.
  ///
  /// On success: saves session data, updates [appInitProvider], and sets state
  /// to `data(user)`.
  ///
  /// On failure: maps the raw error to a user-friendly message and sets state
  /// to `error(message, stackTrace)`.
  Future<void> signIn(String email, String password) async {
    state = const AsyncValue.loading();

    try {
      final repo = ref.read(authRepositoryProvider);
      final user = await repo.signIn(email, password);

      state = AsyncValue.data(user);
      CrashlyticsService().setUserId(user.id);

      final storage = ref.read(storageServiceProvider);
      final onboardingDone = await storage.getOnboardingComplete(user.id);

      if (onboardingDone != true) {
        ref.read(appInitProvider.notifier).state = AppInitState.needsOnboarding;
      } else {
        ref.read(appInitProvider.notifier).state = AppInitState.ready;
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(_mapError(error), stackTrace);
    }
  }

  /// Signs the current user out and resets all app state.
  Future<void> signOut() async {
    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.signOut();
    } catch (_) {
      // Best-effort sign-out: even if the server call fails, reset local state.
    }

    ref.read(appInitProvider.notifier).state = AppInitState.unauthenticated;
    state = const AsyncValue.data(null);
  }

  /// Called by feature repositories when they receive a 401/unauthorized error.
  ///
  /// Triggers a full sign-out, which causes GoRouter to redirect to `/login`.
  Future<void> handleUnauthorized() => signOut();

  /// Directly sets the current user (used by the splash auth-check path).
  void setCurrentUser(AppUser user) {
    state = AsyncValue.data(user);
  }

  // ---------------------------------------------------------------------------
  // Error mapping
  // ---------------------------------------------------------------------------

  String _mapError(Object error) {
    final msg = error.toString().toLowerCase();

    if (msg.contains('invalid') ||
        msg.contains('incorrect') ||
        msg.contains('wrong') ||
        (msg.contains('not found') && msg.contains('password'))) {
      return 'Invalid email or password.';
    }
    if (msg.contains('inactive') || msg.contains('deactivated')) {
      return 'Your account is inactive. Contact your gym admin.';
    }
    if (msg.contains('not found') || msg.contains('registration is closed')) {
      return 'Account not found. Contact your gym admin.';
    }
    if (msg.contains('network') || msg.contains('connection')) {
      return 'No connection. Check your internet.';
    }
    return 'Sign in failed. Please try again.';
  }
}
