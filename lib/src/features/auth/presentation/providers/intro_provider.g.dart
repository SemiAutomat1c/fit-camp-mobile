// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'intro_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$introNotifierHash() => r'98509fb69e2e98e9ac586cf4474f6af7ffb426d2';

/// Tracks whether the user has seen the onboarding intro carousel.
///
/// State is a [bool]:
/// - `false` — intro not yet seen (show carousel)
/// - `true` — intro has been seen (skip to login)
///
/// Copied from [IntroNotifier].
@ProviderFor(IntroNotifier)
final introNotifierProvider =
    AutoDisposeNotifierProvider<IntroNotifier, bool>.internal(
      IntroNotifier.new,
      name: r'introNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$introNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$IntroNotifier = AutoDisposeNotifier<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
