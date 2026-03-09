import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/convex_chat_repository.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';

part 'chat_provider.g.dart';

// ---------------------------------------------------------------------------
// Conversations — trainer list
// ---------------------------------------------------------------------------

@riverpod
class ConversationsNotifier extends _$ConversationsNotifier {
  @override
  Future<List<Conversation>> build() async {
    final repo = ref.watch(chatRepositoryProvider);
    return repo.getMyConversations();
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}

// ---------------------------------------------------------------------------
// Single conversation — member
// ---------------------------------------------------------------------------

@riverpod
class MemberConversationNotifier extends _$MemberConversationNotifier {
  @override
  Future<Conversation?> build() async {
    final repo = ref.watch(chatRepositoryProvider);
    return repo.getMyConversation();
  }

  Future<String> ensureConversation() async {
    final current = state.valueOrNull;
    if (current != null) return current.id;

    final repo = ref.read(chatRepositoryProvider);
    final conversationId = await repo.startConversation();
    ref.invalidateSelf();
    await future;
    return conversationId;
  }
}

// ---------------------------------------------------------------------------
// Messages — for a given conversation
// ---------------------------------------------------------------------------

@riverpod
Future<List<Message>> messages(Ref ref, String conversationId) async {
  final repo = ref.watch(chatRepositoryProvider);
  return repo.getMessages(conversationId);
}

// ---------------------------------------------------------------------------
// Pending (optimistic) messages — per conversation
// ---------------------------------------------------------------------------

@riverpod
class PendingMessages extends _$PendingMessages {
  @override
  List<Message> build(String conversationId) => [];

  void addPending(Message msg) {
    state = [...state, msg];
  }

  void removePending(String tempId) {
    state = state.where((m) => m.id != tempId).toList();
  }

  void markFailed(String tempId) {
    state = state
        .map((m) => m.id == tempId
            ? m.copyWith(isFailed: true, isPending: false)
            : m)
        .toList();
  }
}
