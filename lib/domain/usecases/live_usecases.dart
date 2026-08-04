import '../entities/live_message.dart';
import '../repositories/live_repository.dart';
import 'usecase.dart';

class StreamLiveMessagesUseCase {
  StreamLiveMessagesUseCase(this._repository);

  final LiveRepository _repository;

  Stream<List<LiveMessage>> call(String eventId) {
    return _repository.streamMessages(eventId: eventId);
  }
}

class SendLiveMessageParams {
  const SendLiveMessageParams({required this.eventId, required this.content});

  final String eventId;
  final String content;
}

class SendLiveMessageUseCase
    implements UseCase<LiveMessage, SendLiveMessageParams> {
  SendLiveMessageUseCase(this._repository);

  final LiveRepository _repository;

  @override
  Future<LiveMessage> call(SendLiveMessageParams params) {
    return _repository.sendMessage(
      eventId: params.eventId,
      content: params.content,
    );
  }
}
