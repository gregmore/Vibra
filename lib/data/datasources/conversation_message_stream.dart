import 'dart:async';

import '../models/message_model.dart';

/// Combines the two directions of one conversation. Each source is filtered
/// before its server limit, so activity in other chats cannot displace history.
Stream<List<MessageModel>> conversationMessageStream({
  required Stream<List<Map<String, dynamic>>> incoming,
  required Stream<List<Map<String, dynamic>>> outgoing,
  required String userId,
  required String otherUserId,
  int limit = 200,
}) {
  late StreamController<List<MessageModel>> controller;
  StreamSubscription<List<Map<String, dynamic>>>? incomingSubscription;
  StreamSubscription<List<Map<String, dynamic>>>? outgoingSubscription;
  List<Map<String, dynamic>>? incomingRows;
  List<Map<String, dynamic>>? outgoingRows;
  var completedSources = 0;

  void emit() {
    if (controller.isClosed || incomingRows == null || outgoingRows == null) {
      return;
    }
    try {
      final byId = <String, MessageModel>{};
      for (final row in [...incomingRows!, ...outgoingRows!]) {
        final message = MessageModel.fromJson(row);
        if (message.deletedBy.contains(userId)) continue;
        if ((message.senderId == userId && message.receiverId == otherUserId) ||
            (message.senderId == otherUserId && message.receiverId == userId)) {
          byId[message.id] = message;
        }
      }
      final messages = byId.values.toList()
        ..sort((a, b) {
          final order = (b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0))
              .compareTo(a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0));
          return order == 0 ? b.id.compareTo(a.id) : order;
        });
      controller.add(messages.take(limit).toList(growable: false));
    } catch (error, stackTrace) {
      controller.addError(error, stackTrace);
    }
  }

  void onDone() {
    completedSources++;
    if (completedSources == 2) unawaited(controller.close());
  }

  controller = StreamController<List<MessageModel>>(
    onListen: () {
      incomingSubscription = incoming.listen(
        (rows) {
          incomingRows = rows;
          emit();
        },
        onError: controller.addError,
        onDone: onDone,
      );
      outgoingSubscription = outgoing.listen(
        (rows) {
          outgoingRows = rows;
          emit();
        },
        onError: controller.addError,
        onDone: onDone,
      );
    },
    onPause: () {
      incomingSubscription?.pause();
      outgoingSubscription?.pause();
    },
    onResume: () {
      incomingSubscription?.resume();
      outgoingSubscription?.resume();
    },
    onCancel: () async {
      await Future.wait([
        if (incomingSubscription != null) incomingSubscription!.cancel(),
        if (outgoingSubscription != null) outgoingSubscription!.cancel(),
      ]);
    },
  );
  return controller.stream;
}
