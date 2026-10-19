import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:vibra/data/datasources/conversation_message_stream.dart';

Map<String, dynamic> message(
  String id,
  int minute, {
  String sender = 'me',
  String receiver = 'other',
  List<String> deletedBy = const [],
}) => {
  'id': id,
  'sender_id': sender,
  'receiver_id': receiver,
  'content': id,
  'created_at': DateTime.utc(2026, 10, 13, 12, minute).toIso8601String(),
  'deleted_by': deletedBy,
};

void main() {
  test(
    'Combines both directions, keeping newest visible messages only',
    () async {
      final result = await conversationMessageStream(
        incoming: Stream.value([
          message('incoming', 4, sender: 'other', receiver: 'me'),
          message('another-chat', 5, sender: 'stranger'),
          message(
            'deleted',
            6,
            sender: 'other',
            receiver: 'me',
            deletedBy: ['me'],
          ),
        ]),
        outgoing: Stream.value([
          message('old', 1),
          message('new', 7),
          message('new', 7),
          message('visible-to-me', 3, deletedBy: ['other']),
        ]),
        userId: 'me',
        otherUserId: 'other',
        limit: 3,
      ).first;
      expect(result.map((m) => m.id), ['new', 'incoming', 'visible-to-me']);
    },
  );

  test(
    'Live snapshots replace history instead of retaining removed messages',
    () async {
      final incoming = StreamController<List<Map<String, dynamic>>>();
      final outgoing = StreamController<List<Map<String, dynamic>>>();
      final results = <List<String>>[];
      final subscription = conversationMessageStream(
        incoming: incoming.stream,
        outgoing: outgoing.stream,
        userId: 'me',
        otherUserId: 'other',
      ).listen((items) => results.add(items.map((item) => item.id).toList()));
      incoming.add([]);
      outgoing.add([message('old', 1)]);
      await Future<void>.delayed(Duration.zero);
      outgoing.add([message('new', 2)]);
      await Future<void>.delayed(Duration.zero);
      expect(results, [
        ['old'],
        ['new'],
      ]);
      await subscription.cancel();
      expect(incoming.hasListener, isFalse);
      expect(outgoing.hasListener, isFalse);
      await incoming.close();
      await outgoing.close();
    },
  );

  test(
    'Source failures reach the UI instead of becoming an empty chat',
    () async {
      final incoming = StreamController<List<Map<String, dynamic>>>();
      final outgoing = StreamController<List<Map<String, dynamic>>>();
      final failure = StateError('offline');
      final stream = conversationMessageStream(
        incoming: incoming.stream,
        outgoing: outgoing.stream,
        userId: 'me',
        otherUserId: 'other',
      );
      final expectation = expectLater(stream, emitsError(same(failure)));
      incoming.addError(failure);
      await expectation;
      await incoming.close();
      await outgoing.close();
    },
  );
}
