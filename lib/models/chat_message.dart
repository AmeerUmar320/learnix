class ChatMessage {
  final int id;
  final int senderId;
  final String senderName;
  final String content;
  final DateTime sentAt;
  final bool isMe;
  final String? profilePic;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.sentAt,
    required this.isMe,
    this.profilePic,
  });

  // Factory for messages from API
  factory ChatMessage.fromJson(Map<String, dynamic> json, int myUserId) {
    return ChatMessage(
      id: json['id'],
      senderId: json['userId'],
      senderName: json['userName'] ?? "Unknown",
      content: json['text'],
      sentAt: DateTime.parse(json['sentAt']),
      isMe: json['userId'] == myUserId,
      profilePic: json['userProfilePic'] as String?,
    );
  }
}
