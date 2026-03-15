// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$authNotifierHash() => r'b7f258c140fd27fb42cfb9dfbfdafe1d72798645';

/// Manages the current authenticated user's state across the app lifecycle.
///
/// State: [AsyncValue<AppUser?>]
/// - `data(null)` — initial / signed out
/// - `loading()` — sign-in or token check in progress
/// - `data(user)` — authenticated
/// - `error(msg, st)` — last auth operation failed
///
/// Use [authNotifierProvider] to watch state and call methods.
///
/// Copied from [AuthNotifier].
@ProviderFor(AuthNotifier)
final authNotifierProvider =
    AutoDisposeNotifierProvider<AuthNotifier, AsyncValue<AppUser?>>.internal(
      AuthNotifier.new,
      name: r'authNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$authNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AuthNotifier = AutoDisposeNotifier<AsyncValue<AppUser?>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
