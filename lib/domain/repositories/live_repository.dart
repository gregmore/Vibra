import '../entities/live_message.dart';

abstract class LiveRepository {
  Stream<List<LiveMessage>> streamMessages({required String eventId});

  Future<LiveMessage> sendMessage({
    required String eventId,
    required String content,
  });
}
