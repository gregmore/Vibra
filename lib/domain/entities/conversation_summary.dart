/// Riepilogo di una conversazione 1:1.
class ConversationSummary {
  const ConversationSummary({
    required this.otherUserId,
    required this.otherUsername,
    this.otherDisplayName,
    this.otherAvatarUrl,
    required this.lastMessageContent,
    required this.lastMessageCreatedAt,
    this.lastMessageSenderId,
    required this.unreadCount,
    required this.isFriend,
    required this.isMessageRequest,
  });

  final String otherUserId;
  final String otherUsername;
  final String? otherDisplayName;
  final String? otherAvatarUrl;
  final String lastMessageContent;
  final DateTime lastMessageCreatedAt;
  final String? lastMessageSenderId;
  final int unreadCount;
  final bool isFriend;
  final bool isMessageRequest;

  String get effectiveDisplayName =>
      (otherDisplayName != null && otherDisplayName!.trim().isNotEmpty)
      ? otherDisplayName!
      : otherUsername;

  ConversationSummary copyWith({
    String? otherUserId,
    String? otherUsername,
    String? otherDisplayName,
    String? otherAvatarUrl,
    String? lastMessageContent,
    DateTime? lastMessageCreatedAt,
    String? lastMessageSenderId,
    int? unreadCount,
    bool? isFriend,
    bool? isMessageRequest,
  }) {
    return ConversationSummary(
      otherUserId: otherUserId ?? this.otherUserId,
      otherUsername: otherUsername ?? this.otherUsername,
      otherDisplayName: otherDisplayName ?? this.otherDisplayName,
      otherAvatarUrl: otherAvatarUrl ?? this.otherAvatarUrl,
      lastMessageContent: lastMessageContent ?? this.lastMessageContent,
      lastMessageCreatedAt: lastMessageCreatedAt ?? this.lastMessageCreatedAt,
      lastMessageSenderId: lastMessageSenderId ?? this.lastMessageSenderId,
      unreadCount: unreadCount ?? this.unreadCount,
      isFriend: isFriend ?? this.isFriend,
      isMessageRequest: isMessageRequest ?? this.isMessageRequest,
    );
  }
}
