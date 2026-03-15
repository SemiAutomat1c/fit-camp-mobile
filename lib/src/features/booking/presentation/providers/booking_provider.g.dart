// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$myTrainerIdHash() => r'905eaf75442793e150cbf0a681548d28ce964632';

/// See also [myTrainerId].
@ProviderFor(myTrainerId)
final myTrainerIdProvider = AutoDisposeFutureProvider<String?>.internal(
  myTrainerId,
  name: r'myTrainerIdProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$myTrainerIdHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MyTrainerIdRef = AutoDisposeFutureProviderRef<String?>;
String _$trainerAvailabilityHash() =>
    r'b8aa3f1097aa6e7c490646f2625958fa9fab3393';

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

/// See also [trainerAvailability].
@ProviderFor(trainerAvailability)
const trainerAvailabilityProvider = TrainerAvailabilityFamily();

/// See also [trainerAvailability].
class TrainerAvailabilityFamily extends Family<AsyncValue<List<TrainerSlot>>> {
  /// See also [trainerAvailability].
  const TrainerAvailabilityFamily();

  /// See also [trainerAvailability].
  TrainerAvailabilityProvider call(String trainerId) {
    return TrainerAvailabilityProvider(trainerId);
  }

  @override
  TrainerAvailabilityProvider getProviderOverride(
    covariant TrainerAvailabilityProvider provider,
  ) {
    return call(provider.trainerId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'trainerAvailabilityProvider';
}

/// See also [trainerAvailability].
class TrainerAvailabilityProvider
    extends AutoDisposeFutureProvider<List<TrainerSlot>> {
  /// See also [trainerAvailability].
  TrainerAvailabilityProvider(String trainerId)
    : this._internal(
        (ref) => trainerAvailability(ref as TrainerAvailabilityRef, trainerId),
        from: trainerAvailabilityProvider,
        name: r'trainerAvailabilityProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$trainerAvailabilityHash,
        dependencies: TrainerAvailabilityFamily._dependencies,
        allTransitiveDependencies:
            TrainerAvailabilityFamily._allTransitiveDependencies,
        trainerId: trainerId,
      );

  TrainerAvailabilityProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.trainerId,
  }) : super.internal();

  final String trainerId;

  @override
  Override overrideWith(
    FutureOr<List<TrainerSlot>> Function(TrainerAvailabilityRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TrainerAvailabilityProvider._internal(
        (ref) => create(ref as TrainerAvailabilityRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        trainerId: trainerId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<TrainerSlot>> createElement() {
    return _TrainerAvailabilityProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TrainerAvailabilityProvider && other.trainerId == trainerId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, trainerId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TrainerAvailabilityRef
    on AutoDisposeFutureProviderRef<List<TrainerSlot>> {
  /// The parameter `trainerId` of this provider.
  String get trainerId;
}

class _TrainerAvailabilityProviderElement
    extends AutoDisposeFutureProviderElement<List<TrainerSlot>>
    with TrainerAvailabilityRef {
  _TrainerAvailabilityProviderElement(super.provider);

  @override
  String get trainerId => (origin as TrainerAvailabilityProvider).trainerId;
}

String _$bookingsNotifierHash() => r'caa1a4bfdf296ba30624dcd76afa3bc3aa4c77a8';

/// See also [BookingsNotifier].
@ProviderFor(BookingsNotifier)
final bookingsNotifierProvider =
    AutoDisposeAsyncNotifierProvider<BookingsNotifier, List<Booking>>.internal(
      BookingsNotifier.new,
      name: r'bookingsNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$bookingsNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$BookingsNotifier = AutoDisposeAsyncNotifier<List<Booking>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
