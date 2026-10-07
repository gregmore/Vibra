import '../entities/conversation_summary.dart';
import '../entities/direct_message.dart';
import '../entities/follow_stats.dart';
import '../entities/friendship.dart';

abstract class SocialRepository {
  Future<Friendship> requestFriendship({required String receiverId});

  Future<Friendship> respondFriendship({
    required String friendshipId,
    required String status,
  });

  Future<void> deleteFriendship({required String friendshipId});

  Future<void> cancelFriendRequest({required String friendshipId});

  Future<List<Friendship>> listMyFriendships({String? status});

  Future<DirectMessage> sendMessage({
    required String receiverId,
    required String content,
    String messageType = 'text',
    Map<String, dynamic>? metadata,
  });

  Future<void> blockUser({required String blockedId});
  Future<void> reportUser({
    required String reportedId,
    required String reason,
    String? description,
    String? messageId,
  });
  Future<void> softDeleteChat({required String otherUserId});
  Future<void> reactToMessage({
    required String messageId,
    required String reaction,
  });

  Future<List<DirectMessage>> listMessagesWith({
    required String otherUserId,
    int limit = 50,
  });

  Stream<List<DirectMessage>> streamMessagesWith({required String otherUserId});

  Future<void> markMessagesAsRead({required String otherUserId});

  Future<List<ConversationSummary>> listConversations();

  Future<void> followUser({required String userId});

  Future<void> unfollowUser({required String userId});

  Future<FollowStats> getFollowStats({required String userId});

  Future<List<Map<String, dynamic>>> getFollowers({
    required String userId,
    int limit = 50,
    int offset = 0,
  });

  Future<List<Map<String, dynamic>>> getFollowing({
    required String userId,
    int limit = 50,
    int offset = 0,
  });
}
