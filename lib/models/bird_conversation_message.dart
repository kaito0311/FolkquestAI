class BirdConversationMessage {
  BirdConversationMessage({
    required this.text,
    required this.isUser,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? _nextCreatedAt();

  static DateTime? _lastGeneratedCreatedAt;

  static DateTime _nextCreatedAt() {
    final now = DateTime.now();
    final last = _lastGeneratedCreatedAt;
    final next = last != null && !now.isAfter(last)
        ? last.add(const Duration(microseconds: 1))
        : now;
    _lastGeneratedCreatedAt = next;
    return next;
  }

  final String text;
  final bool isUser;
  final DateTime createdAt;
}
