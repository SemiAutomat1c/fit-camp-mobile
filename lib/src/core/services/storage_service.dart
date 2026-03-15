import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure key-value storage for sensitive auth data.
///
/// Wraps [FlutterSecureStorage] with typed helpers for token, user ID,
/// and role. All values are stored encrypted via the platform keychain
/// (iOS Keychain / Android Keystore).
class StorageService {
  StorageService() : _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  final FlutterSecureStorage _storage;

  // ---------------------------------------------------------------------------
  // Key constants
  // ---------------------------------------------------------------------------

  static const String _keyToken = 'fit_camp_auth_token';
  static const String _keyRefreshToken = 'fit_camp_refresh_token';
  static const String _keyUserId = 'fit_camp_user_id';
  static const String _keyRole = 'fit_camp_user_role';

  // ---------------------------------------------------------------------------
  // Token
  // ---------------------------------------------------------------------------

  /// Persists the Convex JWT auth token.
  Future<void> saveToken(String token) =>
      _storage.write(key: _keyToken, value: token);

  /// Returns the stored JWT token, or null if not present.
  Future<String?> getToken() => _storage.read(key: _keyToken);

  /// Removes the stored JWT token (logout).
  Future<void> deleteToken() => _storage.delete(key: _keyToken);

  /// Persists the Convex refresh token for session renewal.
  Future<void> saveRefreshToken(String token) =>
      _storage.write(key: _keyRefreshToken, value: token);

  /// Returns the stored refresh token, or null if not present.
  Future<String?> getRefreshToken() => _storage.read(key: _keyRefreshToken);

  // ---------------------------------------------------------------------------
  // User ID
  // ---------------------------------------------------------------------------

  /// Persists the authenticated user's Convex document ID.
  Future<void> saveUserId(String id) =>
      _storage.write(key: _keyUserId, value: id);

  /// Returns the stored user ID, or null if not present.
  Future<String?> getUserId() => _storage.read(key: _keyUserId);

  // ---------------------------------------------------------------------------
  // Role
  // ---------------------------------------------------------------------------

  /// Persists the user's role string (e.g. `'member'`, `'trainer'`, `'admin'`).
  Future<void> saveRole(String role) =>
      _storage.write(key: _keyRole, value: role);

  /// Returns the stored role string, or null if not present.
  Future<String?> getRole() => _storage.read(key: _keyRole);

  // ---------------------------------------------------------------------------
  // Onboarding
  // ---------------------------------------------------------------------------

  /// Marks onboarding as complete for [userId].
  ///
  /// Scoped to the user ID so switching accounts resets the onboarding flag.
  Future<void> saveOnboardingComplete(String userId) =>
      _storage.write(key: 'fit_camp_onboarding_$userId', value: 'true');

  /// Returns true if onboarding is marked complete for [userId], else false.
  Future<bool> getOnboardingComplete(String userId) async {
    final val = await _storage.read(key: 'fit_camp_onboarding_$userId');
    return val == 'true';
  }

  // ---------------------------------------------------------------------------
  // Notification preferences
  // ---------------------------------------------------------------------------

  /// Saves a notification preference boolean by key.
  Future<void> saveNotificationPref(String key, bool value) =>
      _storage.write(key: 'fit_camp_notif_$key', value: value.toString());

  /// Gets a notification preference boolean by key. Returns null if not set.
  Future<bool?> getNotificationPref(String key) async {
    final val = await _storage.read(key: 'fit_camp_notif_$key');
    if (val == null) return null;
    return val == 'true';
  }

  // ---------------------------------------------------------------------------
  // Intro seen
  // ---------------------------------------------------------------------------

  /// Marks the onboarding intro carousel as seen.
  Future<void> saveIntroSeen() =>
      _storage.write(key: 'fit_camp_intro_seen', value: 'true');

  /// Returns true if the intro carousel has been seen before.
  Future<bool> getIntroSeen() async {
    final val = await _storage.read(key: 'fit_camp_intro_seen');
    return val == 'true';
  }

  // ---------------------------------------------------------------------------
  // Completed workout count
  // ---------------------------------------------------------------------------

  /// Increments the completed workout count and returns new count.
  Future<int> incrementCompletedWorkoutCount() async {
    final current = await getCompletedWorkoutCount();
    final next = current + 1;
    await _storage.write(key: 'fit_camp_workout_count', value: next.toString());
    return next;
  }

  /// Returns the number of completed workouts.
  Future<int> getCompletedWorkoutCount() async {
    final val = await _storage.read(key: 'fit_camp_workout_count');
    return int.tryParse(val ?? '0') ?? 0;
  }

  // ---------------------------------------------------------------------------
  // Full wipe
  // ---------------------------------------------------------------------------

  /// Deletes all stored values. Called on logout or account deletion.
  Future<void> deleteAll() => _storage.deleteAll();
}
