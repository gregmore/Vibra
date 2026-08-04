class DirectMessage {
  const DirectMessage({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    this.messageType = 'text',
    this.metadata,
    this.reactions,
    this.deletedBy = const [],
    this.readAt,
    this.createdAt,
  });

  final String id;
  final String senderId;
  final String receiverId;
  final String content;
  final String messageType;
  final Map<String, dynamic>? metadata;
  final Map<String, dynamic>? reactions;
  final List<String> deletedBy;
  final DateTime? readAt;
  final DateTime? createdAt;
}
