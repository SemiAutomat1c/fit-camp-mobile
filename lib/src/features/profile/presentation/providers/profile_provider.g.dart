// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$myProfileHash() => r'526df41e69d6e56c6056a875a56c4fcec8ec1855';

/// Fetches the current user's fitness profile from Convex.
///
/// Returns `null` if no profile has been created yet (pre-onboarding state).
///
/// Copied from [myProfile].
@ProviderFor(myProfile)
final myProfileProvider =
    AutoDisposeFutureProvider<Map<String, dynamic>?>.internal(
      myProfile,
      name: r'myProfileProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$myProfileHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MyProfileRef = AutoDisposeFutureProviderRef<Map<String, dynamic>?>;
String _$mySubscriptionHash() => r'c8a6c45918bd50656257e4c574dc079f152194ac';

/// Fetches the current user's active subscription from Convex.
///
/// Returns `null` if there is no active subscription on record.
///
/// Copied from [mySubscription].
@ProviderFor(mySubscription)
final mySubscriptionProvider =
    AutoDisposeFutureProvider<Map<String, dynamic>?>.internal(
      mySubscription,
      name: r'mySubscriptionProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$mySubscriptionHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MySubscriptionRef = AutoDisposeFutureProviderRef<Map<String, dynamic>?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
