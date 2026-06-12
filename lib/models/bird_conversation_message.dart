class BirdConversationMessage {
  BirdConversationMessage({
    required this.text,
    required this.isUser,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  final String text;
  final bool isUser;
  final DateTime createdAt;
}
