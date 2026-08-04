import '../entities/event.dart';

abstract class EventsRepository {
  Future<List<Event>> searchNearbyExternal({
    required double latitude,
    required double longitude,
    required int radiusKm,
  });

  Future<List<Event>> searchByArtistExternal({
    required String artistName,
    String? spotifyArtistId,
  });

  Future<List<Event>> listEventsFromDb({int limit = 50});

  Future<List<Event>> listNearbyEventsFromDb({
    required double latitude,
    required double longitude,
    required double radiusMeters,
  });
  Future<EventAttendee> setAttendance({
    required Event event,
    required String status,
  });

  Future<List<EventAttendee>> listAttendees({required String eventId});

  Future<void> logInteraction({
    required Event event,
    required String interactionType,
    double? scoreAtTime,
    Map<String, dynamic>? metadata,
  });
}

