// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$messagesHash() => r'76996ca9729ccc38e9ce098503de5236d995b0da';

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

/// See also [messages].
@ProviderFor(messages)
const messagesProvider = MessagesFamily();

/// See also [messages].
class MessagesFamily extends Family<AsyncValue<List<Message>>> {
  /// See also [messages].
  const MessagesFamily();

  /// See also [messages].
  MessagesProvider call(String conversationId) {
    return MessagesProvider(conversationId);
  }

  @override
  MessagesProvider getProviderOverride(covariant MessagesProvider provider) {
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
  String? get name => r'messagesProvider';
}

/// See also [messages].
class MessagesProvider extends AutoDisposeFutureProvider<List<Message>> {
  /// See also [messages].
  MessagesProvider(String conversationId)
    : this._internal(
        (ref) => messages(ref as MessagesRef, conversationId),
        from: messagesProvider,
        name: r'messagesProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$messagesHash,
        dependencies: MessagesFamily._dependencies,
        allTransitiveDependencies: MessagesFamily._allTransitiveDependencies,
        conversationId: conversationId,
      );

  MessagesProvider._internal(
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
    FutureOr<List<Message>> Function(MessagesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MessagesProvider._internal(
        (ref) => create(ref as MessagesRef),
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
  AutoDisposeFutureProviderElement<List<Message>> createElement() {
    return _MessagesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MessagesProvider && other.conversationId == conversationId;
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
mixin MessagesRef on AutoDisposeFutureProviderRef<List<Message>> {
  /// The parameter `conversationId` of this provider.
  String get conversationId;
}

class _MessagesProviderElement
    extends AutoDisposeFutureProviderElement<List<Message>>
    with MessagesRef {
  _MessagesProviderElement(super.provider);

  @override
  String get conversationId => (origin as MessagesProvider).conversationId;
}

String _$unreadChatCountHash() => r'55fa31497751ec5ba36381397859062147b4c745';

/// See also [unreadChatCount].
@ProviderFor(unreadChatCount)
final unreadChatCountProvider = AutoDisposeFutureProvider<int>.internal(
  unreadChatCount,
  name: r'unreadChatCountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$unreadChatCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UnreadChatCountRef = AutoDisposeFutureProviderRef<int>;
String _$conversationsNotifierHash() =>
    r'060e64d80e744dd4b7dc2f68154f71c1023c4694';

/// See also [ConversationsNotifier].
@ProviderFor(ConversationsNotifier)
final conversationsNotifierProvider =
    AutoDisposeAsyncNotifierProvider<
      ConversationsNotifier,
      List<Conversation>
    >.internal(
      ConversationsNotifier.new,
      name: r'conversationsNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$conversationsNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ConversationsNotifier = AutoDisposeAsyncNotifier<List<Conversation>>;
String _$memberConversationNotifierHash() =>
    r'47acd032f1d3139928295438e94f280bc12078ea';

/// See also [MemberConversationNotifier].
@ProviderFor(MemberConversationNotifier)
final memberConversationNotifierProvider =
    AutoDisposeAsyncNotifierProvider<
      MemberConversationNotifier,
      Conversation?
    >.internal(
      MemberConversationNotifier.new,
      name: r'memberConversationNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$memberConversationNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$MemberConversationNotifier = AutoDisposeAsyncNotifier<Conversation?>;
String _$pendingMessagesHash() => r'7e5e14d07c6bba9c6620c10b73e4aff842cef3a5';

abstract class _$PendingMessages
    extends BuildlessAutoDisposeNotifier<List<Message>> {
  late final String conversationId;

  List<Message> build(String conversationId);
}

/// See also [PendingMessages].
@ProviderFor(PendingMessages)
const pendingMessagesProvider = PendingMessagesFamily();

/// See also [PendingMessages].
class PendingMessagesFamily extends Family<List<Message>> {
  /// See also [PendingMessages].
  const PendingMessagesFamily();

  /// See also [PendingMessages].
  PendingMessagesProvider call(String conversationId) {
    return PendingMessagesProvider(conversationId);
  }

  @override
  PendingMessagesProvider getProviderOverride(
    covariant PendingMessagesProvider provider,
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
  String? get name => r'pendingMessagesProvider';
}

/// See also [PendingMessages].
class PendingMessagesProvider
    extends AutoDisposeNotifierProviderImpl<PendingMessages, List<Message>> {
  /// See also [PendingMessages].
  PendingMessagesProvider(String conversationId)
    : this._internal(
        () => PendingMessages()..conversationId = conversationId,
        from: pendingMessagesProvider,
        name: r'pendingMessagesProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$pendingMessagesHash,
        dependencies: PendingMessagesFamily._dependencies,
        allTransitiveDependencies:
            PendingMessagesFamily._allTransitiveDependencies,
        conversationId: conversationId,
      );

  PendingMessagesProvider._internal(
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
  List<Message> runNotifierBuild(covariant PendingMessages notifier) {
    return notifier.build(conversationId);
  }

  @override
  Override overrideWith(PendingMessages Function() create) {
    return ProviderOverride(
      origin: this,
      override: PendingMessagesProvider._internal(
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
  AutoDisposeNotifierProviderElement<PendingMessages, List<Message>>
  createElement() {
    return _PendingMessagesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PendingMessagesProvider &&
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
mixin PendingMessagesRef on AutoDisposeNotifierProviderRef<List<Message>> {
  /// The parameter `conversationId` of this provider.
  String get conversationId;
}

class _PendingMessagesProviderElement
    extends AutoDisposeNotifierProviderElement<PendingMessages, List<Message>>
    with PendingMessagesRef {
  _PendingMessagesProviderElement(super.provider);

  @override
  String get conversationId =>
      (origin as PendingMessagesProvider).conversationId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
