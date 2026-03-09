import 'dart:convert';

import 'package:convex_flutter/convex_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/models/app_user.dart';
import '../../../core/services/convex_provider.dart';
import '../../../core/services/storage_service.dart';
import 'auth_repository.dart';

// ---------------------------------------------------------------------------
// NOTE: The convex_flutter SDK calls .toString() on every top-level arg
// value, which means nested Map objects are serialized as Dart's
// "{key: value}" syntax — not valid JSON — and the server receives them as
// opaque strings. To work around this, all auth calls go through thin
// `mobile:mobile*` wrapper actions on the backend that accept flat string
// args and construct the proper nested params object server-side.
// ---------------------------------------------------------------------------

part 'convex_auth_repository.g.dart';

/// Convex-backed implementation of [AuthRepository].
///
/// All auth calls are routed through the `auth:*` and `mobile:*` namespaces
/// on the Convex backend. Session tokens are persisted via [StorageService]
/// (FlutterSecureStorage — iOS Keychain / Android Keystore).
///
/// TODO: Verify exact convex_flutter 3.x session-token API once the package
/// source is confirmed. The pattern `client.sessionToken` is a best-guess;
/// update to the actual getter if the package uses a different name.
class ConvexAuthRepository implements AuthRepository {
  const ConvexAuthRepository({
    required this.client,
    required this.storage,
  });

  final ConvexClient client;
  final StorageService storage;

  // ---------------------------------------------------------------------------
  // AuthRepository
  // ---------------------------------------------------------------------------

  @override
  Future<AppUser> signIn(String email, String password) async {
    // Step 1: Sign in via the mobile wrapper action. The wrapper accepts flat
    // string args and assembles the nested params object server-side, bypassing
    // the SDK's .toString() serialization limitation.
    final signInResult = await client.action(
      name: 'mobile:mobileSignIn',
      args: {
        'email': email,
        'password': password,
      },
    );

    // Step 2: Parse the combined response.
    // Shape: {"tokens":{"refreshToken":"...","token":"eyJ..."}, "profile":{...}}
    final resultMap = jsonDecode(signInResult) as Map<String, dynamic>;
    final tokens = resultMap['tokens'] as Map<String, dynamic>?;
    final jwt = tokens?['token'] as String?;
    final refreshToken = tokens?['refreshToken'] as String?;
    final profileData = resultMap['profile'] as Map<String, dynamic>?;

    if (profileData == null) {
      throw Exception('Sign-in succeeded but profile not found.');
    }

    // The profile response nests user-level fields (name, email, role, etc.)
    // inside a "user" sub-object. AppUser.fromJson expects them at top level,
    // so we merge the user sub-object with the profile ID.
    final userData = profileData['user'] as Map<String, dynamic>? ?? {};
    final userJson = <String, dynamic>{
      ...userData,
      // Ensure the user's _id is used (not the profile doc _id)
      '_id': userData['_id'] ?? profileData['userId'],
    };
    final user = AppUser.fromJson(userJson);

    // Step 3: Persist tokens and set auth on the client for future queries.
    // Skip setAuth on web — the convex_flutter web implementation has a bug
    // where setAuth corrupts the WebSocket protocol state, causing an infinite
    // reconnect loop. On native (iOS/Android) it works correctly.
    if (jwt != null) {
      await storage.saveToken(jwt);
      if (!kIsWeb) {
        await client.setAuth(token: jwt);
      }
    }
    if (refreshToken != null) {
      await storage.saveRefreshToken(refreshToken);
    }
    await storage.saveUserId(user.id);
    await storage.saveRole(user.role.name);

    return user;
  }

  @override
  Future<void> signOut() async {
    try {
      await client.action(name: 'mobile:mobileSignOut', args: {});
    } catch (_) {
      // Best-effort — even if the server call fails, clear local data so the
      // user is not stuck in a broken auth state.
    }
    await storage.deleteAll();
  }

  @override
  Future<AppUser?> getCurrentUser() async {
    try {
      final result =
          jsonDecode(await client.query('mobile:getMyProfile', {})) as Map<String, dynamic>;
      return AppUser.fromJson(result);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<String?> sendPasswordResetOtp(String email) async {
    await client.action(
      name: 'mobile:mobileSendPasswordResetOtp',
      args: {'email': email},
    );
    return email;
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    await client.action(
      name: 'mobile:mobileResetPassword',
      args: {
        'email': email,
        'newPassword': newPassword,
        'code': otp,
      },
    );
  }

}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

@riverpod
AuthRepository authRepository(Ref ref) => ConvexAuthRepository(
      client: ref.watch(convexClientProvider),
      storage: ref.watch(storageServiceProvider),
    );
