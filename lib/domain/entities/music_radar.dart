import 'event.dart';
import 'same_frequency.dart';

/// Music Radar (docs/music-radar.md). The server never sends locations,
/// distances or cells: only who is within the caller's radius, the area's
/// aggregate sound, and nearby events.
enum RadarStatus { disabled, locationNeeded, ok }

enum RadarPrecision {
  /// ~5 km cell.
  area,

  /// ~20 km cell.
  region;

  static RadarPrecision fromName(Object? v) => v == 'region' ? region : area;
}

class RadarSettings {
  const RadarSettings({
    this.enabled = false,
    this.visible = true,
    this.distanceKm = 25,
    this.precision = RadarPrecision.area,
    this.locationConsent = false,
    this.matchingConsent = false,
  });

  static const distances = [5, 10, 25, 50];

  final bool enabled;
  final bool visible;
  final int distanceKm;
  final RadarPrecision precision;
  final bool locationConsent;
  final bool matchingConsent;

  RadarSettings copyWith({
    bool? enabled,
    bool? visible,
    int? distanceKm,
    RadarPrecision? precision,
  }) => RadarSettings(
    enabled: enabled ?? this.enabled,
    visible: visible ?? this.visible,
    distanceKm: distanceKm ?? this.distanceKm,
    precision: precision ?? this.precision,
    locationConsent: locationConsent,
    matchingConsent: matchingConsent,
  );

  static RadarSettings fromJson(Object? raw) {
    if (raw is! Map) return const RadarSettings();
    final distance = (raw['distance_km'] as num?)?.toInt();
    return RadarSettings(
      enabled: raw['enabled'] == true,
      visible: raw['visible'] != false,
      distanceKm: distances.contains(distance) ? distance! : 25,
      precision: RadarPrecision.fromName(raw['precision']),
      locationConsent: raw['location_consent'] == true,
      matchingConsent: raw['matching_consent'] == true,
    );
  }
}

class AreaGenre {
  const AreaGenre(this.family, this.share);
  final String family;

  /// Average share of this family among nearby people's DNA (0..1).
  final double share;
}

/// Why a nearby event is suggested.
enum RadarEventReason { yourArtist, sharedArtist, yourGenre, areaGenre }

class RadarEvent {
  const RadarEvent(this.event, this.reason);
  final Event event;
  final RadarEventReason? reason;
}

/// A nearby person and their connection state with the caller.
class RadarPerson {
  const RadarPerson(this.candidate, {this.connection});
  final FrequencyCandidate candidate;

  /// 'accepted' / 'pending' when already connected or requested.
  final String? connection;
  bool get canSendVibra => connection == null;
}

class MusicRadar {
  const MusicRadar({
    required this.status,
    required this.settings,
    this.compatibleCount = 0,
    this.areaGenres = const [],
    this.people = const [],
    this.events = const [],
  });

  final RadarStatus status;
  final RadarSettings settings;
  final int compatibleCount;
  final List<AreaGenre> areaGenres;
  final List<RadarPerson> people;
  final List<RadarEvent> events;

  MusicRadar copyWith({RadarSettings? settings, List<RadarPerson>? people}) =>
      MusicRadar(
        status: status,
        settings: settings ?? this.settings,
        compatibleCount: compatibleCount,
        areaGenres: areaGenres,
        people: people ?? this.people,
        events: events,
      );

  /// [parseEvent] turns a server event row into an [Event] (data layer).
  static MusicRadar fromJson(
    Object? raw, {
    required Event? Function(Map<String, dynamic>) parseEvent,
  }) {
    if (raw is! Map) {
      return const MusicRadar(
        status: RadarStatus.disabled,
        settings: RadarSettings(),
      );
    }
    final status = switch (raw['status']) {
      'ok' => RadarStatus.ok,
      'location_needed' => RadarStatus.locationNeeded,
      _ => RadarStatus.disabled,
    };
    List<Map<String, dynamic>> rows(Object? v) => v is List
        ? [
            for (final e in v)
              if (e is Map) Map<String, dynamic>.from(e),
          ]
        : const [];
    return MusicRadar(
      status: status,
      settings: RadarSettings.fromJson(raw['settings']),
      compatibleCount: (raw['compatible_count'] as num?)?.toInt() ?? 0,
      areaGenres: [
        for (final g in rows(raw['area_genres']))
          if (g['family'] is String && g['share'] is num)
            AreaGenre(
              g['family'] as String,
              (g['share'] as num).toDouble().clamp(0, 1).toDouble(),
            ),
      ],
      people: [
        for (final row in rows(raw['profiles']))
          if (FrequencyCandidate.fromRow(row) case final c?)
            RadarPerson(c, connection: row['connection'] as String?),
      ],
      events: [
        for (final row in rows(raw['events']))
          if (parseEvent(row) case final e?)
            RadarEvent(e, switch (row['reason']) {
              'your_artist' => RadarEventReason.yourArtist,
              'shared_artist' => RadarEventReason.sharedArtist,
              'your_genre' => RadarEventReason.yourGenre,
              'area_genre' => RadarEventReason.areaGenre,
              _ => null,
            }),
      ],
    );
  }
}
