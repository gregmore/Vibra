import '../../domain/entities/conversation_summary.dart';
import '../../domain/entities/direct_message.dart';
import '../../domain/entities/follow_stats.dart';
import '../../domain/entities/friendship.dart';
import '../../domain/repositories/social_repository.dart';
import '../datasources/supabase_social_datasource.dart';
import '../mappers/domain_mappers.dart';

/// Repository concreto per funzionalità social (amicizie + chat 1:1 + follower).
class SocialRepositoryImpl implements SocialRepository {
  SocialRepositoryImpl(this._datasource);

  final SupabaseSocialDatasource _datasource;

  @override
  Future<Friendship> requestFriendship({required String receiverId}) async {
    final model = await _datasource.requestFriendship(receiverId: receiverId);
    return model.toEntity();
  }

  @override
  Future<Friendship> respondFriendship({
    required String friendshipId,
    required String status,
  }) async {
    final model = await _datasource.respondFriendship(
      friendshipId: friendshipId,
      status: status,
    );
    return model.toEntity();
  }

  @override
  Future<void> deleteFriendship({required String friendshipId}) {
    return _datasource.deleteFriendship(friendshipId: friendshipId);
  }

  @override
  Future<void> cancelFriendRequest({required String friendshipId}) {
    return _datasource.cancelFriendRequest(friendshipId: friendshipId);
  }

  @override
  Future<List<Friendship>> listMyFriendships({String? status}) async {
    final models = await _datasource.listMyFriendships(status: status);
    return models.map((item) => item.toEntity()).toList(growable: false);
  }

  @override
  Future<DirectMessage> sendMessage({
    required String receiverId,
    required String content,
    String messageType = 'text',
    Map<String, dynamic>? metadata,
  }) async {
    final model = await _datasource.sendMessage(
      receiverId: receiverId,
      content: content,
      messageType: messageType,
      metadata: metadata,
    );
    return model.toEntity();
  }

  @override
  Future<void> blockUser({required String blockedId}) {
    return _datasource.blockUser(blockedId: blockedId);
  }

  @override
  Future<void> reportUser({
    required String reportedId,
    required String reason,
    String? description,
    String? messageId,
  }) {
    return _datasource.reportUser(
      reportedId: reportedId,
      reason: reason,
      description: description,
      messageId: messageId,
    );
  }

  @override
  Future<void> softDeleteChat({required String otherUserId}) {
    return _datasource.softDeleteChat(otherUserId: otherUserId);
  }

  @override
  Future<void> reactToMessage({
    required String messageId,
    required String reaction,
  }) {
    return _datasource.reactToMessage(messageId: messageId, reaction: reaction);
  }

  @override
  Future<List<DirectMessage>> listMessagesWith({
    required String otherUserId,
    int limit = 50,
  }) async {
    final models = await _datasource.listMessagesWith(
      otherUserId: otherUserId,
      limit: limit,
    );
    return models.map((item) => item.toEntity()).toList(growable: false);
  }

  @override
  Stream<List<DirectMessage>> streamMessagesWith({
    required String otherUserId,
  }) {
    return _datasource
        .streamMessagesWith(otherUserId: otherUserId)
        .map(
          (models) =>
              models.map((item) => item.toEntity()).toList(growable: false),
        );
  }

  @override
  Future<void> markMessagesAsRead({required String otherUserId}) {
    return _datasource.markMessagesAsRead(otherUserId: otherUserId);
  }

  @override
  Future<List<ConversationSummary>> listConversations() {
    return _datasource.listConversations();
  }

  @override
  Future<void> followUser({required String userId}) {
    return _datasource.followUser(userId: userId);
  }

  @override
  Future<void> unfollowUser({required String userId}) {
    return _datasource.unfollowUser(userId: userId);
  }

  @override
  Future<FollowStats> getFollowStats({required String userId}) {
    return _datasource.getFollowStats(userId: userId);
  }

  @override
  Future<List<Map<String, dynamic>>> getFollowers({
    required String userId,
    int limit = 50,
    int offset = 0,
  }) {
    return _datasource.getFollowers(
      userId: userId,
      limit: limit,
      offset: offset,
    );
  }

  @override
  Future<List<Map<String, dynamic>>> getFollowing({
    required String userId,
    int limit = 50,
    int offset = 0,
  }) {
    return _datasource.getFollowing(
      userId: userId,
      limit: limit,
      offset: offset,
    );
  }
}
