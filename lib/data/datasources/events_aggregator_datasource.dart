import '../../core/utils/logger.dart';
import '../models/event_model.dart';
import 'bandsintown_datasource.dart';

/// Normalizza gli eventi Bandsintown; gli altri cataloghi arrivano dal backend.
class EventsAggregatorDatasource {
  EventsAggregatorDatasource({this.bandsintown, this.nearbySearch});

  final BandsintownDatasource? bandsintown;
  final Future<List<EventModel>> Function(double, double, int)? nearbySearch;

  // La ricerca geografica usa il catalogo Supabase e le Edge Functions.
  Future<List<EventModel>> searchNearby({
    required double latitude,
    required double longitude,
    required int radiusKm,
  }) async => nearbySearch == null
      ? const []
      : nearbySearch!(latitude, longitude, radiusKm);

  Future<List<EventModel>> searchByArtist({
    required String artistName,
    String? spotifyArtistId,
  }) async {
    final results = <EventModel>[];

    // Bandsintown (opzionale)
    final bandsintownLocal = bandsintown;
    if (bandsintownLocal != null) {
      try {
        final raw = await bandsintownLocal.getArtistEvents(
          artistName: artistName,
        );
        results.addAll(raw.map(_fromBandsintown));
      } catch (e) {
        VibraLogger.warning(
          'Bandsintown non disponibile: $e',
          tag: 'EventsAgg',
        );
      }
    }

    return _deduplicateEvents(results);
  }

  // ─────────────────────────────────────────────────────────────
  // Deduplication
  // ─────────────────────────────────────────────────────────────

  List<EventModel> _deduplicateEvents(List<EventModel> events) {
    final Map<String, EventModel> uniqueEvents = {};

    for (final event in events) {
      // Create a composite key based on normalized name and date (YYYY-MM-DD)
      final normalizedName = event.name.toLowerCase().replaceAll(
        RegExp(r'[^a-z0-9]'),
        '',
      );
      final dateKey =
          '${event.eventDate.year}-${event.eventDate.month}-${event.eventDate.day}';
      final cityKey =
          event.city?.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '') ?? '';

      final key = '${normalizedName}_${dateKey}_$cityKey';

      uniqueEvents.putIfAbsent(key, () => event);
    }

    return uniqueEvents.values.toList();
  }

  // ─────────────────────────────────────────────────────────────
  // Mapping
  // ─────────────────────────────────────────────────────────────

  EventModel _fromBandsintown(dynamic json) {
    final m = json as Map<String, dynamic>;
    final externalId = (m['id'] ?? '').toString();
    final title = (m['title'] as String?) ?? 'Evento';
    final dt = m['datetime'] as String?;
    final eventDate = dt != null ? DateTime.parse(dt) : DateTime.now();
    final venue = m['venue'] as Map<String, dynamic>?;

    return EventModel(
      id: '00000000-0000-0000-0000-000000000000',
      externalId: externalId,
      source: 'bandsintown',
      name: title,
      artistName: (m['artist'] as Map?)?['name'] as String?,
      artistSpotifyId: null,
      venueName: venue?['name'] as String?,
      city: venue?['city'] as String?,
      country: venue?['country'] as String?,
      latitude: (venue?['latitude'] as num?)?.toDouble(),
      longitude: (venue?['longitude'] as num?)?.toDouble(),
      eventDate: eventDate,
      ticketUrl: m['url'] as String?,
      priceMin: null,
      priceMax: null,
      imageUrl: null,
      description: null,
      createdAt: null,
    );
  }
}
