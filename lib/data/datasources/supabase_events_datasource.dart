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
        'get_nearby_events_with_distance',
        params: {
          'user_lat': latitude,
          'user_lon': longitude,
          'radius_meters': radiusMeters,
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

      // Salviamo anche gli eventi nearby in cache per avere sempre qualcosa sulla mappa offline
      await CacheService.saveList(
        '${CacheService.keyEvents}_nearby',
        events.map((e) => e.toJson()).toList(),
      );
      return events;
    } catch (e) {
      final cachedJson = CacheService.getList(
        '${CacheService.keyEvents}_nearby',
      );
      if (cachedJson != null && cachedJson.isNotEmpty) {
        return cachedJson.map(EventModel.fromJson).toList(growable: false);
      }
      throw ServerException(
        message: 'Errore RPC get_nearby_events_with_distance e cache vuota',
        endpoint: 'rpc/get_nearby_events_with_distance',
      );
    }
  }

  Future<String> syncEvent(EventModel event) async {
    final payload = {
      'external_id': event.externalId,
      'source': event.source,
      'name': event.name,
      'artist_name': event.artistName,
      'artist_spotify_id': event.artistSpotifyId,
      'venue_name': event.venueName,
      'city': event.city,
      'country': event.country,
      'latitude': event.latitude,
      'longitude': event.longitude,
      'event_date': event.eventDate.toUtc().toIso8601String(),
      'ticket_url': event.ticketUrl,
      'price_min': event.priceMin,
      'price_max': event.priceMax,
      'image_url': event.imageUrl,
      'description': event.description,
    };

    final row = await _supabase.upsert(
      DbTables.events,
      payload,
      onConflict: 'source,external_id',
    );
    return row['id'] as String;
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
