/// Caller-scoped permission: no location or blocking direction is exposed.
enum DirectMessagePermission {
  allowed,
  friends,
  friendshipRequired,
  awaitingReply,
  rateLimited,
  unavailable;

  bool get canSend => this == allowed || this == friends;

  static DirectMessagePermission fromServer(Object? value) => switch (value) {
    'allowed' => allowed,
    'allowed_friend' => friends,
    'friendship_required' => friendshipRequired,
    'awaiting_reply' => awaitingReply,
    'rate_limited' => rateLimited,
    _ => unavailable,
  };
}

class DirectMessageSendException implements Exception {
  const DirectMessageSendException(this.permission);
  final DirectMessagePermission permission;
}
