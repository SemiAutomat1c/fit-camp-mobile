// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'active_workout_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$planCompletionHash() => r'835d3354b05ae402704ac7057d116cd38bcc7d2a';

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

/// See also [planCompletion].
@ProviderFor(planCompletion)
const planCompletionProvider = PlanCompletionFamily();

/// See also [planCompletion].
class PlanCompletionFamily extends Family<double> {
  /// See also [planCompletion].
  const PlanCompletionFamily();

  /// See also [planCompletion].
  PlanCompletionProvider call(String planId) {
    return PlanCompletionProvider(planId);
  }

  @override
  PlanCompletionProvider getProviderOverride(
    covariant PlanCompletionProvider provider,
  ) {
    return call(provider.planId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'planCompletionProvider';
}

/// See also [planCompletion].
class PlanCompletionProvider extends AutoDisposeProvider<double> {
  /// See also [planCompletion].
  PlanCompletionProvider(String planId)
    : this._internal(
        (ref) => planCompletion(ref as PlanCompletionRef, planId),
        from: planCompletionProvider,
        name: r'planCompletionProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$planCompletionHash,
        dependencies: PlanCompletionFamily._dependencies,
        allTransitiveDependencies:
            PlanCompletionFamily._allTransitiveDependencies,
        planId: planId,
      );

  PlanCompletionProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.planId,
  }) : super.internal();

  final String planId;

  @override
  Override overrideWith(double Function(PlanCompletionRef provider) create) {
    return ProviderOverride(
      origin: this,
      override: PlanCompletionProvider._internal(
        (ref) => create(ref as PlanCompletionRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        planId: planId,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<double> createElement() {
    return _PlanCompletionProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PlanCompletionProvider && other.planId == planId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, planId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PlanCompletionRef on AutoDisposeProviderRef<double> {
  /// The parameter `planId` of this provider.
  String get planId;
}

class _PlanCompletionProviderElement extends AutoDisposeProviderElement<double>
    with PlanCompletionRef {
  _PlanCompletionProviderElement(super.provider);

  @override
  String get planId => (origin as PlanCompletionProvider).planId;
}

String _$activeWorkoutNotifierHash() =>
    r'd9d97cb1650dfb47f30a10264bcdaa0481506194';

abstract class _$ActiveWorkoutNotifier
    extends BuildlessAutoDisposeNotifier<ActiveWorkoutState> {
  late final String planId;
  late final List<Map<String, dynamic>> exercises;

  ActiveWorkoutState build(String planId, List<Map<String, dynamic>> exercises);
}

/// See also [ActiveWorkoutNotifier].
@ProviderFor(ActiveWorkoutNotifier)
const activeWorkoutNotifierProvider = ActiveWorkoutNotifierFamily();

/// See also [ActiveWorkoutNotifier].
class ActiveWorkoutNotifierFamily extends Family<ActiveWorkoutState> {
  /// See also [ActiveWorkoutNotifier].
  const ActiveWorkoutNotifierFamily();

  /// See also [ActiveWorkoutNotifier].
  ActiveWorkoutNotifierProvider call(
    String planId,
    List<Map<String, dynamic>> exercises,
  ) {
    return ActiveWorkoutNotifierProvider(planId, exercises);
  }

  @override
  ActiveWorkoutNotifierProvider getProviderOverride(
    covariant ActiveWorkoutNotifierProvider provider,
  ) {
    return call(provider.planId, provider.exercises);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'activeWorkoutNotifierProvider';
}

/// See also [ActiveWorkoutNotifier].
class ActiveWorkoutNotifierProvider
    extends
        AutoDisposeNotifierProviderImpl<
          ActiveWorkoutNotifier,
          ActiveWorkoutState
        > {
  /// See also [ActiveWorkoutNotifier].
  ActiveWorkoutNotifierProvider(
    String planId,
    List<Map<String, dynamic>> exercises,
  ) : this._internal(
        () => ActiveWorkoutNotifier()
          ..planId = planId
          ..exercises = exercises,
        from: activeWorkoutNotifierProvider,
        name: r'activeWorkoutNotifierProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$activeWorkoutNotifierHash,
        dependencies: ActiveWorkoutNotifierFamily._dependencies,
        allTransitiveDependencies:
            ActiveWorkoutNotifierFamily._allTransitiveDependencies,
        planId: planId,
        exercises: exercises,
      );

  ActiveWorkoutNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.planId,
    required this.exercises,
  }) : super.internal();

  final String planId;
  final List<Map<String, dynamic>> exercises;

  @override
  ActiveWorkoutState runNotifierBuild(
    covariant ActiveWorkoutNotifier notifier,
  ) {
    return notifier.build(planId, exercises);
  }

  @override
  Override overrideWith(ActiveWorkoutNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: ActiveWorkoutNotifierProvider._internal(
        () => create()
          ..planId = planId
          ..exercises = exercises,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        planId: planId,
        exercises: exercises,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<ActiveWorkoutNotifier, ActiveWorkoutState>
  createElement() {
    return _ActiveWorkoutNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ActiveWorkoutNotifierProvider &&
        other.planId == planId &&
        other.exercises == exercises;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, planId.hashCode);
    hash = _SystemHash.combine(hash, exercises.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ActiveWorkoutNotifierRef
    on AutoDisposeNotifierProviderRef<ActiveWorkoutState> {
  /// The parameter `planId` of this provider.
  String get planId;

  /// The parameter `exercises` of this provider.
  List<Map<String, dynamic>> get exercises;
}

class _ActiveWorkoutNotifierProviderElement
    extends
        AutoDisposeNotifierProviderElement<
          ActiveWorkoutNotifier,
          ActiveWorkoutState
        >
    with ActiveWorkoutNotifierRef {
  _ActiveWorkoutNotifierProviderElement(super.provider);

  @override
  String get planId => (origin as ActiveWorkoutNotifierProvider).planId;
  @override
  List<Map<String, dynamic>> get exercises =>
      (origin as ActiveWorkoutNotifierProvider).exercises;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
