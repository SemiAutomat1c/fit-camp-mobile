// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'typing_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$isOtherTypingHash() => r'97b581dac37fc65052afe3a0368320ea4d909797';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [isOtherTyping].
@ProviderFor(isOtherTyping)
const isOtherTypingProvider = IsOtherTypingFamily();

/// See also [isOtherTyping].
class IsOtherTypingFamily extends Family<AsyncValue<bool>> {
  /// See also [isOtherTyping].
  const IsOtherTypingFamily();

  /// See also [isOtherTyping].
  IsOtherTypingProvider call(String conversationId) {
    return IsOtherTypingProvider(conversationId);
  }

  @override
  IsOtherTypingProvider getProviderOverride(
    covariant IsOtherTypingProvider provider,
  ) {
    return call(provider.conversationId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'isOtherTypingProvider';
}

/// See also [isOtherTyping].
class IsOtherTypingProvider extends AutoDisposeFutureProvider<bool> {
  /// See also [isOtherTyping].
  IsOtherTypingProvider(String conversationId)
    : this._internal(
        (ref) => isOtherTyping(ref as IsOtherTypingRef, conversationId),
        from: isOtherTypingProvider,
        name: r'isOtherTypingProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$isOtherTypingHash,
        dependencies: IsOtherTypingFamily._dependencies,
        allTransitiveDependencies:
            IsOtherTypingFamily._allTransitiveDependencies,
        conversationId: conversationId,
      );

  IsOtherTypingProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.conversationId,
  }) : super.internal();

  final String conversationId;

  @override
  Override overrideWith(
    FutureOr<bool> Function(IsOtherTypingRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: IsOtherTypingProvider._internal(
        (ref) => create(ref as IsOtherTypingRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        conversationId: conversationId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<bool> createElement() {
    return _IsOtherTypingProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is IsOtherTypingProvider &&
        other.conversationId == conversationId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, conversationId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin IsOtherTypingRef on AutoDisposeFutureProviderRef<bool> {
  /// The parameter `conversationId` of this provider.
  String get conversationId;
}

class _IsOtherTypingProviderElement
    extends AutoDisposeFutureProviderElement<bool>
    with IsOtherTypingRef {
  _IsOtherTypingProviderElement(super.provider);

  @override
  String get conversationId => (origin as IsOtherTypingProvider).conversationId;
}

String _$typingNotifierHash() => r'11f6f674db4fb5c36092e9459f4158d21aa26e7e';

abstract class _$TypingNotifier extends BuildlessAutoDisposeNotifier<bool> {
  late final String conversationId;

  bool build(String conversationId);
}

/// See also [TypingNotifier].
@ProviderFor(TypingNotifier)
const typingNotifierProvider = TypingNotifierFamily();

/// See also [TypingNotifier].
class TypingNotifierFamily extends Family<bool> {
  /// See also [TypingNotifier].
  const TypingNotifierFamily();

  /// See also [TypingNotifier].
  TypingNotifierProvider call(String conversationId) {
    return TypingNotifierProvider(conversationId);
  }

  @override
  TypingNotifierProvider getProviderOverride(
    covariant TypingNotifierProvider provider,
  ) {
    return call(provider.conversationId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'typingNotifierProvider';
}

/// See also [TypingNotifier].
class TypingNotifierProvider
    extends AutoDisposeNotifierProviderImpl<TypingNotifier, bool> {
  /// See also [TypingNotifier].
  TypingNotifierProvider(String conversationId)
    : this._internal(
        () => TypingNotifier()..conversationId = conversationId,
        from: typingNotifierProvider,
        name: r'typingNotifierProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$typingNotifierHash,
        dependencies: TypingNotifierFamily._dependencies,
        allTransitiveDependencies:
            TypingNotifierFamily._allTransitiveDependencies,
        conversationId: conversationId,
      );

  TypingNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.conversationId,
  }) : super.internal();

  final String conversationId;

  @override
  bool runNotifierBuild(covariant TypingNotifier notifier) {
    return notifier.build(conversationId);
  }

  @override
  Override overrideWith(TypingNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: TypingNotifierProvider._internal(
        () => create()..conversationId = conversationId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        conversationId: conversationId,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<TypingNotifier, bool> createElement() {
    return _TypingNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TypingNotifierProvider &&
        other.conversationId == conversationId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, conversationId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TypingNotifierRef on AutoDisposeNotifierProviderRef<bool> {
  /// The parameter `conversationId` of this provider.
  String get conversationId;
}

class _TypingNotifierProviderElement
    extends AutoDisposeNotifierProviderElement<TypingNotifier, bool>
    with TypingNotifierRef {
  _TypingNotifierProviderElement(super.provider);

  @override
  String get conversationId =>
      (origin as TypingNotifierProvider).conversationId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
