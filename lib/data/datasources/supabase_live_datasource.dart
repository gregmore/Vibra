import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constants/db_tables.dart';
import '../../core/errors/exceptions.dart' as app_exceptions;
import '../models/live_message_model.dart';
import 'supabase_datasource.dart';

/// Datasource Supabase per chat live evento (Realtime).
class SupabaseLiveDatasource {
  SupabaseLiveDatasource(this._supabase);

  final SupabaseDatasource _supabase;

  Stream<List<LiveMessageModel>> streamLiveMessages({
    required String eventId,
  }) {
    final stream = _supabase.client
        .from(DbTables.liveMessages)
        .stream(primaryKey: ['id'])
        .eq('event_id', eventId)
        .order('created_at', ascending: false)
        .limit(200);

    return stream.map(
      (rows) => rows.map(LiveMessageModel.fromJson).toList(growable: false),
    );
  }

  Future<LiveMessageModel> sendLiveMessage({
    required String eventId,
    required String content,
  }) async {
    final user = _supabase.currentUser;
    if (user == null) throw const app_exceptions.AuthException(message: 'Utente non autenticato');

    final row = await _supabase.insert(
      DbTables.liveMessages,
      {
        'event_id': eventId,
        'user_id': user.id,
        'content': content,
      },
    );
    return LiveMessageModel.fromJson(row);
  }

  RealtimeChannel subscribeToLiveInsert({
    required String eventId,
    required void Function(LiveMessageModel message) onInsert,
  }) {
    return _supabase.subscribeToTable(
      DbTables.liveMessages,
      onInsert: (payload) {
        final record = payload.newRecord;
        if (record['event_id'] == eventId) {
          onInsert(LiveMessageModel.fromJson(record));
        }
      },
    );
  }
}

