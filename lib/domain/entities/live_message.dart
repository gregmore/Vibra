class LiveMessage {
  const LiveMessage({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.content,
    this.createdAt,
  });

  final String id;
  final String eventId;
  final String userId;
  final String content;
  final DateTime? createdAt;
}
