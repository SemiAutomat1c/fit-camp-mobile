class Conversation {
  const Conversation({
    required this.id,
    required this.lastMessageAt,
    this.otherParticipantName,
    this.otherParticipantAvatarUrl,
    this.lastMessageContent,
    this.lastMessageSenderId,
  });

  final String id;
  final DateTime lastMessageAt;
  final String? otherParticipantName;
  final String? otherParticipantAvatarUrl;
  final String? lastMessageContent;
  final String? lastMessageSenderId;

  factory Conversation.fromMemberJson(Map<String, dynamic> json) {
    final trainer = json['trainer'] as Map<String, dynamic>?;
    final lastMsg = json['lastMessage'] as Map<String, dynamic>?;
    return Conversation(
      id: json['_id'] as String,
      lastMessageAt: DateTime.fromMillisecondsSinceEpoch(
          (json['lastMessageAt'] as num).toInt()),
      otherParticipantName: trainer?['name'] as String?,
      otherParticipantAvatarUrl: trainer?['avatarUrl'] as String?,
      lastMessageContent: lastMsg?['content'] as String?,
      lastMessageSenderId: lastMsg?['senderId'] as String?,
    );
  }

  factory Conversation.fromTrainerJson(Map<String, dynamic> json) {
    final member = json['member'] as Map<String, dynamic>?;
    final lastMsg = json['lastMessage'] as Map<String, dynamic>?;
    return Conversation(
      id: json['_id'] as String,
      lastMessageAt: DateTime.fromMillisecondsSinceEpoch(
          (json['lastMessageAt'] as num).toInt()),
      otherParticipantName: member?['name'] as String?,
      otherParticipantAvatarUrl: member?['avatarUrl'] as String?,
      lastMessageContent: lastMsg?['content'] as String?,
      lastMessageSenderId: lastMsg?['senderId'] as String?,
    );
  }
}
