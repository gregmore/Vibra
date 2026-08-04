class Friendship {
  const Friendship({
    required this.id,
    required this.requesterId,
    required this.receiverId,
    required this.status,
    this.createdAt,
  });

  final String id;
  final String requesterId;
  final String receiverId;
  final String status;
  final DateTime? createdAt;
}
