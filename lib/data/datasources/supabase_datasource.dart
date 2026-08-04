import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/errors/exceptions.dart';
import '../../core/utils/logger.dart';

/// Client wrapper per Supabase.
/// Centralizza l'accesso al database, auth e realtime.
class SupabaseDatasource {
  /// Istanza del client Supabase (inizializzata in main.dart).
  SupabaseClient get client => Supabase.instance.client;

  /// Accesso rapido all'utente corrente.
  User? get currentUser => client.auth.currentUser;

  /// Accesso rapido alla sessione corrente.
  Session? get currentSession => client.auth.currentSession;

  /// Stream dello stato di autenticazione.
  Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;

  /// Verifica se l'utente è autenticato.
  bool get isAuthenticated => currentUser != null;

  // ── Database Operations ─────────────────────────────────

  /// Esegue una query SELECT su una tabella.
  /// Wrappa gli errori Supabase in [ServerException].
  Future<List<Map<String, dynamic>>> select(
    String table, {
    String columns = '*',
    Map<String, dynamic>? filters,
    String? orderBy,
    bool ascending = true,
    int? limit,
    int? offset,
  }) async {
    try {
      dynamic query = client.from(table).select(columns);

      // Applica filtri
      if (filters != null) {
        for (final entry in filters.entries) {
          query = query.eq(entry.key, entry.value);
        }
      }

      if (orderBy != null) {
        query = query.order(orderBy, ascending: ascending);
      }

      if (offset != null && limit != null) {
        query = query.range(offset, offset + limit - 1);
      } else if (limit != null) {
        query = query.limit(limit);
      }

      final data = await query;
      VibraLogger.api('SELECT', table);
      return List<Map<String, dynamic>>.from(data as List);
    } catch (e) {
      VibraLogger.error('Errore SELECT su $table', error: e);
      throw ServerException(
        message: 'Errore nel caricamento dati da $table',
        endpoint: table,
      );
    }
  }

  /// Inserisce un record in una tabella.
  Future<Map<String, dynamic>> insert(
    String table,
    Map<String, dynamic> data,
  ) async {
    try {
      final result = await client.from(table).insert(data).select().single();
      VibraLogger.api('INSERT', table);
      return result;
    } catch (e) {
      VibraLogger.error('Errore INSERT su $table', error: e);
      throw ServerException(
        message: 'Errore nel salvataggio dati in $table',
        endpoint: table,
      );
    }
  }

  /// Aggiorna un record in una tabella.
  Future<Map<String, dynamic>> update(
    String table,
    Map<String, dynamic> data, {
    required String matchColumn,
    required dynamic matchValue,
  }) async {
    try {
      final result = await client
          .from(table)
          .update(data)
          .eq(matchColumn, matchValue)
          .select()
          .single();
      VibraLogger.api('UPDATE', table);
      return result;
    } catch (e) {
      VibraLogger.error('Errore UPDATE su $table', error: e);
      throw ServerException(
        message: 'Errore nell\'aggiornamento dati in $table',
        endpoint: table,
      );
    }
  }

  /// Elimina un record da una tabella.
  Future<void> delete(
    String table, {
    required String matchColumn,
    required dynamic matchValue,
  }) async {
    try {
      await client.from(table).delete().eq(matchColumn, matchValue);
      VibraLogger.api('DELETE', table);
    } catch (e) {
      VibraLogger.error('Errore DELETE su $table', error: e);
      throw ServerException(
        message: 'Errore nell\'eliminazione dati da $table',
        endpoint: table,
      );
    }
  }

  /// Esegue un upsert (insert o update se esiste).
  Future<Map<String, dynamic>> upsert(
    String table,
    Map<String, dynamic> data, {
    String? onConflict,
  }) async {
    try {
      final result = await client
          .from(table)
          .upsert(data, onConflict: onConflict)
          .select()
          .single();
      VibraLogger.api('UPSERT', table);
      return result;
    } catch (e) {
      VibraLogger.error('Errore UPSERT su $table', error: e);
      throw ServerException(
        message: 'Errore nel salvataggio dati in $table',
        endpoint: table,
      );
    }
  }

  // ── Realtime ────────────────────────────────────────────

  /// Sottoscrive ai cambiamenti realtime di una tabella.
  RealtimeChannel subscribeToTable(
    String table, {
    required void Function(PostgresChangePayload payload) onInsert,
    void Function(PostgresChangePayload payload)? onUpdate,
    void Function(PostgresChangePayload payload)? onDelete,
  }) {
    final channel = client.channel('public:$table');
    channel.onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: table,
      callback: (payload) => onInsert(payload),
    );
    if (onUpdate != null) {
      channel.onPostgresChanges(
        event: PostgresChangeEvent.update,
        schema: 'public',
        table: table,
        callback: (payload) => onUpdate(payload),
      );
    }
    if (onDelete != null) {
      channel.onPostgresChanges(
        event: PostgresChangeEvent.delete,
        schema: 'public',
        table: table,
        callback: (payload) => onDelete(payload),
      );
    }
    channel.subscribe();
    VibraLogger.info('Sottoscrizione realtime a $table attiva');
    return channel;
  }

  // ── Storage ─────────────────────────────────────────────

  /// Carica un file nello storage Supabase.
  Future<String> uploadFile(
    String bucket,
    String path,
    Uint8List fileBytes, {
    String? contentType,
  }) async {
    try {
      await client.storage
          .from(bucket)
          .uploadBinary(
            path,
            fileBytes,
            fileOptions: FileOptions(contentType: contentType),
          );
      final url = client.storage.from(bucket).getPublicUrl(path);
      VibraLogger.info('File caricato: $path in $bucket');
      return url;
    } catch (e) {
      VibraLogger.error('Errore upload file', error: e);
      throw ServerException(
        message: 'Errore nel caricamento del file',
        endpoint: '$bucket/$path',
      );
    }
  }

  // ── Edge Functions ──────────────────────────────────────

  /// Invoca una Supabase Edge Function.
  Future<Map<String, dynamic>> invokeFunction(
    String functionName, {
    Map<String, dynamic>? body,
  }) async {
    try {
      final response = await client.functions.invoke(functionName, body: body);
      VibraLogger.api('EDGE_FN', functionName);
      return response.data as Map<String, dynamic>;
    } catch (e) {
      VibraLogger.error('Errore Edge Function: $functionName', error: e);
      throw ServerException(
        message: 'Errore nell\'esecuzione della funzione $functionName: $e',
        endpoint: functionName,
      );
    }
  }
}
