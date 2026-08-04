import '../entities/direct_message.dart';
import '../entities/friendship.dart';
import '../repositories/social_repository.dart';
import 'usecase.dart';

class RequestFriendshipUseCase implements UseCase<Friendship, String> {
  RequestFriendshipUseCase(this._repository);

  final SocialRepository _repository;

  @override
  Future<Friendship> call(String params) {
    return _repository.requestFriendship(receiverId: params);
  }
}

class RespondFriendshipParams {
  const RespondFriendshipParams({
    required this.friendshipId,
    required this.status,
  });

  final String friendshipId;
  final String status;
}

class RespondFriendshipUseCase
    implements UseCase<Friendship, RespondFriendshipParams> {
  RespondFriendshipUseCase(this._repository);

  final SocialRepository _repository;

  @override
  Future<Friendship> call(RespondFriendshipParams params) {
    return _repository.respondFriendship(
      friendshipId: params.friendshipId,
      status: params.status,
    );
  }
}

class ListFriendshipsUseCase implements UseCase<List<Friendship>, String?> {
  ListFriendshipsUseCase(this._repository);

  final SocialRepository _repository;

  @override
  Future<List<Friendship>> call(String? params) {
    return _repository.listMyFriendships(status: params);
  }
}

class SendDirectMessageParams {
  const SendDirectMessageParams({
    required this.receiverId,
    required this.content,
  });

  final String receiverId;
  final String content;
}

class SendDirectMessageUseCase
    implements UseCase<DirectMessage, SendDirectMessageParams> {
  SendDirectMessageUseCase(this._repository);

  final SocialRepository _repository;

  @override
  Future<DirectMessage> call(SendDirectMessageParams params) {
    return _repository.sendMessage(
      receiverId: params.receiverId,
      content: params.content,
    );
  }
}

class GetConversationUseCase
    implements UseCase<List<DirectMessage>, GetConversationParams> {
  GetConversationUseCase(this._repository);

  final SocialRepository _repository;

  @override
  Future<List<DirectMessage>> call(GetConversationParams params) {
    return _repository.listMessagesWith(
      otherUserId: params.otherUserId,
      limit: params.limit,
    );
  }
}

class GetConversationParams {
  const GetConversationParams({required this.otherUserId, this.limit = 50});

  final String otherUserId;
  final int limit;
}

class StreamConversationUseCase
    implements UseCase<Stream<List<DirectMessage>>, String> {
  StreamConversationUseCase(this._repository);

  final SocialRepository _repository;

  @override
  Future<Stream<List<DirectMessage>>> call(String params) async {
    return _repository.streamMessagesWith(otherUserId: params);
  }
}

class BlockUserUseCase implements UseCase<void, String> {
  BlockUserUseCase(this._repository);
  final SocialRepository _repository;

  @override
  Future<void> call(String params) {
    return _repository.blockUser(blockedId: params);
  }
}

class ReportUserParams {
  const ReportUserParams({
    required this.reportedId,
    required this.reason,
    this.description,
    this.messageId,
  });
  final String reportedId;
  final String reason;
  final String? description;
  final String? messageId;
}

class ReportUserUseCase implements UseCase<void, ReportUserParams> {
  ReportUserUseCase(this._repository);
  final SocialRepository _repository;

  @override
  Future<void> call(ReportUserParams params) {
    return _repository.reportUser(
      reportedId: params.reportedId,
      reason: params.reason,
      description: params.description,
      messageId: params.messageId,
    );
  }
}

class SoftDeleteChatUseCase implements UseCase<void, String> {
  SoftDeleteChatUseCase(this._repository);
  final SocialRepository _repository;

  @override
  Future<void> call(String params) {
    return _repository.softDeleteChat(otherUserId: params);
  }
}

class ReactToMessageParams {
  const ReactToMessageParams({required this.messageId, required this.reaction});
  final String messageId;
  final String reaction;
}

class ReactToMessageUseCase implements UseCase<void, ReactToMessageParams> {
  ReactToMessageUseCase(this._repository);
  final SocialRepository _repository;

  @override
  Future<void> call(ReactToMessageParams params) {
    return _repository.reactToMessage(
      messageId: params.messageId,
      reaction: params.reaction,
    );
  }
}
