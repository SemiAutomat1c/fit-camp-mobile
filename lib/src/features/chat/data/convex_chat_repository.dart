import 'dart:convert';

import 'package:convex_flutter/convex_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/convex_provider.dart';
import '../domain/entities/conversation.dart';
import '../domain/entities/message.dart';
import 'chat_repository.dart';

class ConvexChatRepository implements ChatRepository {
  const ConvexChatRepository(this._client);

  final ConvexClient _client;

  @override
  Future<Conversation?> getMyConversation() async {
    final raw = jsonDecode(
      await _client.query('mobile:getMyConversation', {}),
    );
    if (raw == null) return null;
    return Conversation.fromMemberJson(raw as Map<String, dynamic>);
  }

  @override
  Future<List<Conversation>> getMyConversations() async {
    final result = jsonDecode(
      await _client.query('mobile:getMyConversations', {}),
    ) as List<dynamic>;
    return result
        .map((e) => Conversation.fromTrainerJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<String> startConversation() async {
    return _client.mutation(
      name: 'mobile:startConversation',
      args: {},
    );
  }

  @override
  Future<List<Message>> getMessages(String conversationId) async {
    final result = jsonDecode(
      await _client.query('messages:listByConversation', {
        'conversationId': jsonEncode(conversationId),
      }),
    ) as List<dynamic>;
    return result
        .map((e) => Message.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<String> sendMessage(String conversationId, String content) async {
    return _client.mutation(
      name: 'mobile:sendMessage',
      args: {
        'conversationId': jsonEncode(conversationId),
        'content': content,
      },
    );
  }

  @override
  Future<void> markRead(String conversationId) async {
    await _client.mutation(
      name: 'messages:markRead',
      args: {'conversationId': jsonEncode(conversationId)},
    );
  }
}

final Provider<ChatRepository> chatRepositoryProvider =
    Provider<ChatRepository>(
  (ref) => ConvexChatRepository(ref.read(convexClientProvider)),
  name: 'chatRepositoryProvider',
);
