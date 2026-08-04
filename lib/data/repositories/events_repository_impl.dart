import '../../core/utils/logger.dart';
import '../../domain/entities/event.dart';
import '../../domain/repositories/events_repository.dart';
import '../datasources/events_aggregator_datasource.dart';
import '../datasources/supabase_events_datasource.dart';
import '../mappers/domain_mappers.dart';

/// Repository concreto per eventi.
class EventsRepositoryImpl implements EventsRepository {
  EventsRepositoryImpl({
    required EventsAggregatorDatasource externalDatasource,
    required SupabaseEventsDatasource supabaseDatasource,
  }) : _external = externalDatasource,
       _supabase = supabaseDatasource;

  final EventsAggregatorDatasource _external;
  final SupabaseEventsDatasource _supabase;

  @override
  Future<List<Event>> searchNearbyExternal({
    required double latitude,
    required double longitude,
    required int radiusKm,
  }) async {
    VibraLogger.info('Search eventi esterni (nearby)', tag: 'EventsRepo');
    final models = await _external.searchNearby(
      latitude: latitude,
      longitude: longitude,
      radiusKm: radiusKm,
    );
    return models.map((item) => item.toEntity()).toList(growable: false);
  }

  @override
  Future<List<Event>> searchByArtistExternal({
    required String artistName,
    String? spotifyArtistId,
  }) async {
    VibraLogger.info('Search eventi esterni (artist)', tag: 'EventsRepo');
    final models = await _external.searchByArtist(
      artistName: artistName,
      spotifyArtistId: spotifyArtistId,
    );
    return models.map((item) => item.toEntity()).toList(growable: false);
  }

  @override
  Future<List<Event>> listEventsFromDb({int limit = 50}) async {
    final models = await _supabase.listEvents(limit: limit);
    return models.map((item) => item.toEntity()).toList(growable: false);
  }

  @override
  Future<List<Event>> listNearbyEventsFromDb({
    required double latitude,
    required double longitude,
    required double radiusMeters,
  }) async {
    final models = await _supabase.getNearbyEventsWithDistance(
      latitude: latitude,
      longitude: longitude,
      radiusMeters: radiusMeters,
    );
    return models.map((item) => item.toEntity()).toList(growable: false);
  }

  @override
  Future<EventAttendee> setAttendance({
    required Event event,
    required String status,
  }) async {
    final internalEventId = await _supabase.syncEvent(event.toModel());
    final model = await _supabase.setAttendance(
      eventId: internalEventId,
      status: status,
    );
    return model.toEntity();
  }

  @override
  Future<List<EventAttendee>> listAttendees({required String eventId}) async {
    final models = await _supabase.listAttendees(eventId: eventId);
    return models.map((item) => item.toEntity()).toList(growable: false);
  }

  @override
  Future<void> logInteraction({
    required Event event,
    required String interactionType,
    double? scoreAtTime,
    Map<String, dynamic>? metadata,
  }) async {
    await _supabase.logInteraction(
      entityType: 'event',
      entityId: event.id,
      interactionType: interactionType,
      scoreAtTime: scoreAtTime,
      metadata: metadata,
    );
  }
}
