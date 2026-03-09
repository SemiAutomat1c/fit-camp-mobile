import '../../../core/models/app_user.dart';

/// Contract for all authentication operations.
///
/// Implemented by [ConvexAuthRepository]. Can be overridden in tests via
/// ProviderScope.overrides without touching any Convex-specific code.
abstract class AuthRepository {
  /// Signs in with email and password.
  ///
  /// Throws on invalid credentials, inactive account, or network errors.
  /// The caller is responsible for mapping errors to user-facing messages.
  Future<AppUser> signIn(String email, String password);

  /// Signs the current user out.
  ///
  /// Clears the server session and all locally stored auth data.
  Future<void> signOut();

  /// Returns the currently authenticated user, or null if not authenticated.
  ///
  /// Used by the splash screen to resume an existing session on app start.
  Future<AppUser?> getCurrentUser();

  /// Sends a one-time password to [email] for password reset.
  ///
  /// Returns the email address that the OTP was sent to (for display), or
  /// null if the server did not return one.
  Future<String?> sendPasswordResetOtp(String email);

  /// Resets the password using the OTP code received by email.
  ///
  /// Throws if the OTP is expired, invalid, or the passwords do not match
  /// server-side constraints.
  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  });
}
