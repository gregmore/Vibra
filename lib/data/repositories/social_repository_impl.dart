import '../../domain/entities/direct_message.dart';
import '../../domain/entities/friendship.dart';
import '../../domain/repositories/social_repository.dart';
import '../datasources/supabase_social_datasource.dart';
import '../mappers/domain_mappers.dart';

/// Repository concreto per funzionalità social (amicizie + chat 1:1).
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
        .map((models) => models.map((item) => item.toEntity()).toList(growable: false));
  }
}
