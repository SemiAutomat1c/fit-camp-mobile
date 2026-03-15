import '../domain/entities/conversation.dart';
import '../domain/entities/message.dart';

abstract class ChatRepository {
  Future<Conversation?> getMyConversation();
  Future<List<Conversation>> getMyConversations();
  Future<String> startConversation();
  Future<List<Message>> getMessages(String conversationId);
  Future<String> sendMessage(String conversationId, String content);
  Future<void> markRead(String conversationId);

  /// Returns a one-time upload URL from Convex storage.
  Future<String> generateUploadUrl();

  /// Sends a message that contains an image identified by [storageId].
  Future<void> sendImageMessage(String conversationId, String storageId);

  /// Returns the number of unread messages across all conversations.
  Future<int> getUnreadCount();
}
