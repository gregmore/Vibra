import '../../core/errors/exceptions.dart';
import '../../core/utils/logger.dart';
import '../models/event_model.dart';
import 'bandsintown_datasource.dart';
import 'events_datasource.dart';
import 'songkick_datasource.dart';

/// Aggrega fonti eventi esterne e normalizza in [EventModel].
/// In Fase 5 useremo Edge Functions per lo scoring, qui ci limitiamo al fetch + mapping.
class EventsAggregatorDatasource {
  EventsAggregatorDatasource({
    this.ticketmaster,
    this.songkick,
    this.bandsintown,
  });

  final TicketmasterDatasource? ticketmaster;
  final SongkickDatasource? songkick;
  final BandsintownDatasource? bandsintown;

  Future<List<EventModel>> searchNearby({
    required double latitude,
    required double longitude,
    required int radiusKm,
  }) async {
    final results = <EventModel>[];

    // Ticketmaster (primaria, opzionale se key presente)
    final ticketmasterLocal = ticketmaster;
    if (ticketmasterLocal != null) {
      try {
        final ticketmasterRaw = await ticketmasterLocal.searchByLocation(
          latitude: latitude,
          longitude: longitude,
          radiusKm: radiusKm,
          page: 0,
          pageSize: 200,
        );
        results.addAll(ticketmasterRaw.map(_fromTicketmaster));
      } catch (e) {
        VibraLogger.warning(
          'Ticketmaster non disponibile: $e',
          tag: 'EventsAgg',
        );
      }
    }

    // Songkick (opzionale)
    final songkickLocal = songkick;
    if (songkickLocal != null) {
      try {
        final raw = await songkickLocal.searchEvents(
          latitude: latitude,
          longitude: longitude,
          radiusKm: radiusKm,
        );
        results.addAll(_fromSongkickSearch(raw));
      } catch (e) {
        VibraLogger.warning('Songkick non disponibile: $e', tag: 'EventsAgg');
      }
    }

    return _deduplicateEvents(results);
  }

  Future<List<EventModel>> searchByArtist({
    required String artistName,
    String? spotifyArtistId,
  }) async {
    final results = <EventModel>[];

    // Ticketmaster
    final ticketmasterLocal = ticketmaster;
    if (ticketmasterLocal != null) {
      try {
        final ticketmasterRaw = await ticketmasterLocal.searchByArtist(
          artistName: artistName,
          spotifyArtistId: spotifyArtistId,
        );
        results.addAll(ticketmasterRaw.map(_fromTicketmaster));
      } catch (e) {
        VibraLogger.warning(
          'Ticketmaster non disponibile: $e',
          tag: 'EventsAgg',
        );
      }
    }

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

      // If we already have this event, prefer Ticketmaster as it usually has more details and images
      if (uniqueEvents.containsKey(key)) {
        if (event.source == 'ticketmaster') {
          uniqueEvents[key] = event;
        }
      } else {
        uniqueEvents[key] = event;
      }
    }

    return uniqueEvents.values.toList();
  }

  // ─────────────────────────────────────────────────────────────
  // Mapping
  // ─────────────────────────────────────────────────────────────

  EventModel _fromTicketmaster(Map<String, dynamic> json) {
    try {
      final externalId = (json['id'] as String?) ?? '';
      final name = (json['name'] as String?) ?? 'Evento';

      final dates = json['dates'] as Map<String, dynamic>?;
      final start = dates?['start'] as Map<String, dynamic>?;
      final dateTimeString = start?['dateTime'] as String?;
      final eventDate = dateTimeString != null
          ? DateTime.parse(dateTimeString)
          : DateTime.now();

      final embedded = json['_embedded'] as Map<String, dynamic>?;
      final attractions = embedded?['attractions'] as List<dynamic>?;
      final firstAttraction = attractions != null && attractions.isNotEmpty
          ? attractions.first
          : null;
      final artistName = (firstAttraction as Map?)?['name'] as String?;

      final venues = embedded?['venues'] as List<dynamic>?;
      final venue = venues != null && venues.isNotEmpty ? venues.first : null;
      final venueMap = venue as Map<String, dynamic>?;
      final venueName = venueMap?['name'] as String?;
      final city = (venueMap?['city'] as Map?)?['name'] as String?;
      final country = (venueMap?['country'] as Map?)?['name'] as String?;
      final location = (venueMap?['location'] as Map?) ?? {};
      final lat = double.tryParse((location['latitude'] ?? '').toString());
      final lng = double.tryParse((location['longitude'] ?? '').toString());

      final images = json['images'] as List<dynamic>?;
      String? imageUrl;
      if (images != null && images.isNotEmpty) {
        imageUrl = (images.first as Map<String, dynamic>)['url'] as String?;
      }

      final url = json['url'] as String?;

      // Per i dati price min/max Ticketmaster ha una struttura complessa. Qui prendiamo un best-effort.
      final priceRanges = json['priceRanges'] as List<dynamic>?;
      double? priceMin;
      double? priceMax;
      if (priceRanges != null && priceRanges.isNotEmpty) {
        final pr = priceRanges.first as Map<String, dynamic>;
        priceMin = (pr['min'] as num?)?.toDouble();
        priceMax = (pr['max'] as num?)?.toDouble();
      }

      final classifications = json['classifications'] as List<dynamic>?;
      String? description =
          json['info'] as String? ?? json['description'] as String?;
      final pleaseNote = json['pleaseNote'] as String?;
      final ticketLimit =
          (json['ticketLimit'] as Map<String, dynamic>?)?['info'] as String?;
      final accessibility =
          (json['accessibility'] as Map<String, dynamic>?)?['info'] as String?;
      final promoterName =
          (json['promoter'] as Map<String, dynamic>?)?['name'] as String?;

      final List<String> extraInfo = [];
      if (description != null && description.trim().isNotEmpty)
        extraInfo.add(description.trim());
      if (pleaseNote != null && pleaseNote.trim().isNotEmpty)
        extraInfo.add('📝 Nota: ${pleaseNote.trim()}');
      if (ticketLimit != null && ticketLimit.trim().isNotEmpty)
        extraInfo.add('🎫 Limite biglietti: ${ticketLimit.trim()}');
      if (accessibility != null && accessibility.trim().isNotEmpty)
        extraInfo.add('♿ Accessibilità: ${accessibility.trim()}');
      if (promoterName != null && promoterName.trim().isNotEmpty)
        extraInfo.add('⭐ Promoter: ${promoterName.trim()}');

      description = extraInfo.isNotEmpty ? extraInfo.join('\n\n') : null;

      if (classifications != null && classifications.isNotEmpty) {
        final cls = classifications.first as Map<String, dynamic>?;
        if (cls != null) {
          final genre =
              (cls['genre'] as Map<String, dynamic>?)?['name'] as String?;
          final subGenre =
              (cls['subGenre'] as Map<String, dynamic>?)?['name'] as String?;

          final parts = <String>[];
          if (genre != null && genre != 'Undefined') parts.add(genre);
          if (subGenre != null && subGenre != 'Undefined') parts.add(subGenre);

          if (parts.isNotEmpty) {
            final genreStr = '[${parts.join(' / ')}]';
            description = description != null
                ? '$genreStr\n$description'
                : genreStr;
          }
        }
      }

      return EventModel(
        id: '00000000-0000-0000-0000-000000000000', // placeholder: verrà sostituito da Supabase
        externalId: externalId,
        source: 'ticketmaster',
        name: name,
        artistName: artistName,
        artistSpotifyId: null,
        venueName: venueName,
        city: city,
        country: country,
        latitude: lat,
        longitude: lng,
        eventDate: eventDate,
        ticketUrl: url,
        priceMin: priceMin,
        priceMax: priceMax,
        status:
            (json['dates']?['status'] as Map<String, dynamic>?)?['code']
                as String?,
        imageUrl: imageUrl,
        description: description,
        createdAt: null,
      );
    } catch (e) {
      throw ServerException(
        message: 'Mapping Ticketmaster fallito: $e',
        endpoint: 'ticketmaster/map',
      );
    }
  }

  List<EventModel> _fromSongkickSearch(Map<String, dynamic> json) {
    try {
      final resultsPage = json['resultsPage'] as Map<String, dynamic>?;
      final results = resultsPage?['results'] as Map<String, dynamic>?;
      final events = results?['event'] as List<dynamic>? ?? const [];

      return events
          .map((e) {
            final m = e as Map<String, dynamic>;
            final externalId = (m['id'] ?? '').toString();
            final displayName = (m['displayName'] ?? 'Evento') as String;
            final start = m['start'] as Map<String, dynamic>?;
            final date =
                start?['datetime'] as String? ?? start?['date'] as String?;
            final eventDate = date != null
                ? DateTime.parse(date)
                : DateTime.now();

            final venue = m['venue'] as Map<String, dynamic>?;
            final venueName = venue?['displayName'] as String?;
            final metroArea = venue?['metroArea'] as Map<String, dynamic>?;
            final city = metroArea?['displayName'] as String?;
            final country =
                (metroArea?['country'] as Map?)?['displayName'] as String?;
            final lat = (metroArea?['lat'] as num?)?.toDouble();
            final lng = (metroArea?['lng'] as num?)?.toDouble();

            final performance = m['performance'] as List<dynamic>?;
            final artistName = performance != null && performance.isNotEmpty
                ? (performance.first as Map<String, dynamic>)['displayName']
                      as String?
                : null;

            return EventModel(
              id: '00000000-0000-0000-0000-000000000000',
              externalId: externalId,
              source: 'songkick',
              name: displayName,
              artistName: artistName,
              artistSpotifyId: null,
              venueName: venueName,
              city: city,
              country: country,
              latitude: lat,
              longitude: lng,
              eventDate: eventDate,
              ticketUrl: m['uri'] as String?,
              priceMin: null,
              priceMax: null,
              imageUrl: null,
              description: null,
              createdAt: null,
            );
          })
          .toList(growable: false);
    } catch (e) {
      VibraLogger.warning('Mapping Songkick fallito: $e', tag: 'EventsAgg');
      return const [];
    }
  }

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
