class Message {
  const Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.content,
    this.senderName,
    this.senderAvatarUrl,
    this.readAt,
    required this.createdAt,
    this.isPending = false,
    this.isFailed = false,
    this.storageId,
    this.imageUrl,
  });

  final String id;
  final String conversationId;
  final String senderId;
  final String content;
  final String? senderName;
  final String? senderAvatarUrl;
  final DateTime? readAt;
  final DateTime createdAt;
  final bool isPending;
  final bool isFailed;

  /// Convex storage ID for an image attached to this message.
  final String? storageId;

  /// Resolved CDN URL for the attached image (populated by the backend).
  final String? imageUrl;

  factory Message.fromJson(Map<String, dynamic> json) {
    final sender = json['sender'] as Map<String, dynamic>?;
    return Message(
      id: json['_id'] as String,
      conversationId: json['conversationId'] as String,
      senderId: json['senderId'] as String,
      content: json['content'] as String? ?? '',
      senderName: sender?['name'] as String?,
      senderAvatarUrl: sender?['avatarUrl'] as String?,
      readAt: json['readAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch((json['readAt'] as num).toInt())
          : null,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
          (json['createdAt'] as num).toInt()),
      storageId: json['storageId'] as String?,
      imageUrl: json['imageUrl'] as String?,
    );
  }

  Message copyWith({
    bool? isPending,
    bool? isFailed,
    String? storageId,
    String? imageUrl,
  }) {
    return Message(
      id: id,
      conversationId: conversationId,
      senderId: senderId,
      content: content,
      senderName: senderName,
      senderAvatarUrl: senderAvatarUrl,
      readAt: readAt,
      createdAt: createdAt,
      isPending: isPending ?? this.isPending,
      isFailed: isFailed ?? this.isFailed,
      storageId: storageId ?? this.storageId,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
