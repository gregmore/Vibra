import '../../core/constants/db_tables.dart';
import '../../core/errors/exceptions.dart';
import '../../core/services/cache_service.dart';
import '../models/event_attendee_model.dart';
import '../models/event_model.dart';
import 'supabase_datasource.dart';

/// Datasource Supabase per eventi e partecipazioni.
class SupabaseEventsDatasource {
  SupabaseEventsDatasource(this._supabase);

  final SupabaseDatasource _supabase;

  Future<List<EventModel>> listEvents({DateTime? from, int limit = 50}) async {
    try {
      final threshold = (from ?? DateTime.now()).toUtc().toIso8601String();
      final rows = await _supabase.client
          .from(DbTables.events)
          .select()
          .gte('event_date', threshold)
          .order('event_date', ascending: true)
          .limit(limit);

      final events = List<Map<String, dynamic>>.from(
        rows,
      ).map(EventModel.fromJson).toList(growable: false);

      // Salva in cache
      await CacheService.saveList(
        CacheService.keyEvents,
        events.map((e) => e.toJson()).toList(),
      );
      return events;
    } catch (e) {
      // Fallback cache
      final cachedJson = CacheService.getList(CacheService.keyEvents);
      if (cachedJson != null && cachedJson.isNotEmpty) {
        return cachedJson.map(EventModel.fromJson).toList(growable: false);
      }
      throw ServerException(
        message: 'Errore nel caricamento degli eventi e cache vuota',
        endpoint: DbTables.events,
      );
    }
  }

  Future<List<EventModel>> getNearbyEventsWithDistance({
    required double latitude,
    required double longitude,
    required double radiusMeters,
  }) async {
    try {
      final rows = await _supabase.client.rpc(
        'find_events_in_radius',
        params: {
          'p_latitude': latitude,
          'p_longitude': longitude,
          'p_radius_meters': radiusMeters,
          'p_status': null,
          'p_limit': 500,
        },
      );
      final events = List<Map<String, dynamic>>.from(rows)
          .map((row) {
            return EventModel.fromJson({
              ...row,
              'latitude': row['location_lat'],
              'longitude': row['location_lon'],
            });
          })
          .toList(growable: false);

      // An offline result is usable only for the area actually queried. The
      // single cache entry avoids persisting a history of device locations.
      await CacheService.saveObject('${CacheService.keyEvents}_nearby', {
        'latitude': latitude,
        'longitude': longitude,
        'radius_meters': radiusMeters,
        'events': events.map((event) => event.toJson()).toList(),
      });
      return events;
    } catch (e) {
      final cached = CacheService.getObject('${CacheService.keyEvents}_nearby');
      if (cached?['latitude'] == latitude &&
          cached?['longitude'] == longitude &&
          cached?['radius_meters'] == radiusMeters &&
          cached?['events'] is List) {
        try {
          final now = DateTime.now();
          return (cached!['events'] as List)
              .map((row) => EventModel.fromJson(Map<String, dynamic>.from(row)))
              .where((event) => event.eventDate.isAfter(now))
              .toList(growable: false);
        } catch (_) {
          // An invalid cache cannot turn an offline error into a parsing crash.
        }
      }
      throw ServerException(
        message: 'Errore RPC find_events_in_radius e cache vuota',
        endpoint: 'rpc/find_events_in_radius',
      );
    }
  }

  /// Refresh the queried area with the provider key retained on the backend.
  Future<List<EventModel>> searchNearbyEvents(
    double latitude,
    double longitude,
    int radiusKm,
  ) async {
    final response = await _supabase.client.functions
        .invoke(
          'search-events',
          body: {
            'latitude': latitude,
            'longitude': longitude,
            'radius_km': radiusKm,
          },
        )
        .timeout(const Duration(seconds: 35));
    if (response.status != 200 ||
        response.data is! Map ||
        response.data['events'] is! List) {
      throw const ServerException(
        message: 'Event provider unavailable',
        endpoint: 'search-events',
      );
    }
    return (response.data['events'] as List)
        .map(
          (row) => EventModel.fromJson({
            ...Map<String, dynamic>.from(row),
            'latitude': row['location_lat'],
            'longitude': row['location_lon'],
          }),
        )
        .toList(growable: false);
  }

  Future<String> syncEvent(EventModel event) async {
    final existingId = await _findEventId(event);
    if (existingId != null) return existingId;
    final response = await _supabase.client.functions.invoke(
      'resolve-event',
      body: {
        'source': event.source,
        'external_id': event.externalId,
        'artist_name': event.artistName,
      },
    );
    if (response.status != 200 ||
        response.data is! Map ||
        response.data['id'] is! String) {
      throw ServerException(
        message:
            'Impossibile verificare l’evento con il fornitore. Riprova più tardi.',
        endpoint: 'resolve-event',
      );
    }
    return response.data['id'] as String;
  }

  Future<String?> _findEventId(EventModel event) async {
    final row = await _supabase.client
        .from(DbTables.events)
        .select('id')
        .eq('source', event.source)
        .eq('external_id', event.externalId)
        .maybeSingle();
    return row?['id'] as String?;
  }

  Future<String?> getMyAttendanceStatus(EventModel event) async {
    final user = _supabase.currentUser;
    if (user == null) return null;

    final eventId = await _findEventId(event);
    if (eventId == null) return null;

    final row = await _supabase.client
        .from(DbTables.eventAttendees)
        .select('status')
        .eq('user_id', user.id)
        .eq('event_id', eventId)
        .maybeSingle();
    return row?['status'] as String?;
  }

  Future<EventAttendeeModel> setAttendance({
    required String eventId,
    required String status,
  }) async {
    final user = _supabase.currentUser;
    if (user == null) {
      throw const AuthException(message: 'Utente non autenticato');
    }

    if (status == 'none') {
      await _supabase.client.from(DbTables.eventAttendees).delete().match({
        'user_id': user.id,
        'event_id': eventId,
      });
      return EventAttendeeModel(
        id: '',
        userId: user.id,
        eventId: eventId,
        status: 'none',
        createdAt: DateTime.now(),
      );
    }

    final payload = <String, dynamic>{
      'user_id': user.id,
      'event_id': eventId,
      'status': status,
    };

    final row = await _supabase.upsert(
      DbTables.eventAttendees,
      payload,
      onConflict: 'user_id,event_id',
    );
    return EventAttendeeModel.fromJson(row);
  }

  Future<List<EventAttendeeModel>> listAttendees({
    required String eventId,
  }) async {
    final rows = await _supabase.select(
      DbTables.eventAttendees,
      filters: {'event_id': eventId},
      orderBy: 'created_at',
      ascending: false,
      limit: 200,
    );
    return rows.map(EventAttendeeModel.fromJson).toList(growable: false);
  }

  Future<void> logInteraction({
    required String entityType,
    required String entityId,
    required String interactionType,
    double? scoreAtTime,
    Map<String, dynamic>? metadata,
  }) async {
    final user = _supabase.currentUser;
    if (user == null) return;

    try {
      await _supabase.client.from('user_interactions_log').insert({
        'user_id': user.id,
        'entity_type': entityType,
        'entity_id': entityId,
        'interaction_type': interactionType,
        'score_at_time': scoreAtTime,
        'metadata': metadata,
      });
    } catch (e) {
      // Non blocchiamo l'app se il log fallisce
      // print('Errore salvataggio log interazione: $e');
    }
  }
}
