import 'event.dart';

/// Concert Intelligence (docs/concert-intelligence.md): one recommended event
/// with the server's reasons. Every reason refers to the user's own data or
/// the event's published data.
sealed class EventReason {
  const EventReason();

  static EventReason? fromJson(Object? raw) {
    if (raw is! Map) return null;
    String? s(String k) => raw[k] is String ? raw[k] as String : null;
    int? n(String k) => raw[k] is num ? (raw[k] as num).toInt() : null;
    return switch (raw['code']) {
      'top_artist' when s('artist') != null && n('rank') != null =>
        TopArtistEventReason(s('artist')!, n('rank')!),
      'track_artist' when s('artist') != null => TrackArtistEventReason(
        s('artist')!,
      ),
      'saved_artist' when s('artist') != null => SavedArtistEventReason(
        s('artist')!,
      ),
      'genre' when s('genre') != null && n('percent') != null =>
        GenreEventReason(s('genre')!, n('percent')!),
      'similar_to_saved' when s('family') != null => SimilarToSavedEventReason(
        s('family')!,
      ),
      'distance' when n('km') != null => DistanceEventReason(n('km')!),
      'soon' when n('days') != null => SoonEventReason(n('days')!),
      _ => null,
    };
  }
}

class TopArtistEventReason extends EventReason {
  const TopArtistEventReason(this.artist, this.rank);
  final String artist;
  final int rank;
}

class TrackArtistEventReason extends EventReason {
  const TrackArtistEventReason(this.artist);
  final String artist;
}

class SavedArtistEventReason extends EventReason {
  const SavedArtistEventReason(this.artist);
  final String artist;
}

class GenreEventReason extends EventReason {
  const GenreEventReason(this.genre, this.percent);
  final String genre;
  final int percent;
}

class SimilarToSavedEventReason extends EventReason {
  const SimilarToSavedEventReason(this.family);
  final String family;
}

class DistanceEventReason extends EventReason {
  const DistanceEventReason(this.km);
  final int km;
}

class SoonEventReason extends EventReason {
  const SoonEventReason(this.days);
  final int days;
}

class RecommendedEvent {
  const RecommendedEvent({
    required this.event,
    required this.relevance,
    this.reasons = const [],
    this.families = const [],
    this.distanceKm,
    this.saved = false,
  });

  final Event event;

  /// 0–100: how well the event fits the user's music.
  final int relevance;
  final List<EventReason> reasons;

  /// Catalogue families of the event's published genres.
  final List<String> families;
  final double? distanceKm;
  final bool saved;
}

/// Where distances were measured from.
enum RecommendationOrigin { device, saved, none }

class ConcertFilters {
  const ConcertFilters({
    this.family,
    this.artist,
    this.dateTo,
    this.radiusKm,
    this.priceMax,
  });

  final String? family;
  final String? artist;
  final DateTime? dateTo;
  final int? radiusKm;

  /// Euros; only events with a published EUR price pass.
  final int? priceMax;

  ConcertFilters copyWith({
    String? Function()? family,
    String? Function()? artist,
    DateTime? Function()? dateTo,
    int? Function()? radiusKm,
    int? Function()? priceMax,
  }) => ConcertFilters(
    family: family == null ? this.family : family(),
    artist: artist == null ? this.artist : artist(),
    dateTo: dateTo == null ? this.dateTo : dateTo(),
    radiusKm: radiusKm == null ? this.radiusKm : radiusKm(),
    priceMax: priceMax == null ? this.priceMax : priceMax(),
  );

  Map<String, dynamic> toBody() => {
    'family': ?family,
    if (artist != null && artist!.trim().isNotEmpty) 'artist': artist!.trim(),
    if (dateTo != null) 'date_to': dateTo!.toUtc().toIso8601String(),
    'radius_km': ?radiusKm,
    'price_max': ?priceMax,
  };

  @override
  bool operator ==(Object other) =>
      other is ConcertFilters &&
      other.family == family &&
      other.artist == artist &&
      other.dateTo == dateTo &&
      other.radiusKm == radiusKm &&
      other.priceMax == priceMax;

  @override
  int get hashCode => Object.hash(family, artist, dateTo, radiusKm, priceMax);
}

class ConcertRecommendations {
  const ConcertRecommendations({
    required this.events,
    required this.origin,
    this.needsMusicProfile = false,
  });

  final List<RecommendedEvent> events;
  final RecommendationOrigin origin;

  /// No Spotify data and no picked genres yet.
  final bool needsMusicProfile;
}
