import '../entities/direct_message.dart';
import '../entities/friendship.dart';

abstract class SocialRepository {
  Future<Friendship> requestFriendship({required String receiverId});

  Future<Friendship> respondFriendship({
    required String friendshipId,
    required String status,
  });

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

  Stream<List<DirectMessage>> streamMessagesWith({
    required String otherUserId,
  });
}

