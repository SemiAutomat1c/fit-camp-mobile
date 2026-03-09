import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/models/app_user.dart';

part 'auth_state.freezed.dart';

/// Union type representing every possible authentication state.
///
/// Consumed by [AuthNotifier] and observed by screens that need to react to
/// auth transitions (e.g., login screen error display, header avatar).
@freezed
sealed class AuthState with _$AuthState {
  /// No user is signed in. Routes to `/login`.
  const factory AuthState.unauthenticated() = _Unauthenticated;

  /// A valid session exists. [user] is the authenticated user.
  const factory AuthState.authenticated(AppUser user) = _Authenticated;

  /// An auth operation (sign-in / sign-out / token check) is in progress.
  const factory AuthState.loading() = _Loading;

  /// An auth operation failed. [message] is the user-facing error string.
  const factory AuthState.error(String message) = _Error;
}
