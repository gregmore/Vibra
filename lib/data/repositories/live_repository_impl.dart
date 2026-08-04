import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/live_message.dart';
import '../../domain/repositories/live_repository.dart';
import '../datasources/supabase_live_datasource.dart';
import '../mappers/domain_mappers.dart';

/// Repository concreto per modalità Live.
class LiveRepositoryImpl implements LiveRepository {
  LiveRepositoryImpl(this._datasource);

  final SupabaseLiveDatasource _datasource;

  @override
  Stream<List<LiveMessage>> streamMessages({required String eventId}) {
    return _datasource
        .streamLiveMessages(eventId: eventId)
        .map(
          (items) =>
              items.map((item) => item.toEntity()).toList(growable: false),
        );
  }

  @override
  Future<LiveMessage> sendMessage({
    required String eventId,
    required String content,
  }) async {
    final model = await _datasource.sendLiveMessage(
      eventId: eventId,
      content: content,
    );
    return model.toEntity();
  }

  RealtimeChannel subscribeToInserts({
    required String eventId,
    required void Function(LiveMessage message) onInsert,
  }) => _datasource.subscribeToLiveInsert(
    eventId: eventId,
    onInsert: (model) => onInsert(model.toEntity()),
  );
}
