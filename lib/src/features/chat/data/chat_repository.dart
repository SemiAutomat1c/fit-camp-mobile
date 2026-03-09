import '../domain/entities/conversation.dart';
import '../domain/entities/message.dart';

abstract class ChatRepository {
  Future<Conversation?> getMyConversation();
  Future<List<Conversation>> getMyConversations();
  Future<String> startConversation();
  Future<List<Message>> getMessages(String conversationId);
  Future<String> sendMessage(String conversationId, String content);
  Future<void> markRead(String conversationId);
}
