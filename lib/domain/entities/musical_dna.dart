/// Musical DNA as computed and stored by the server
/// (supabase/functions/_shared/musical_dna.ts, docs/musical-dna.md).
/// The app only renders it: every percentage comes from the snapshot.
library;

enum DnaVisibility {
  public,
  matches,
  private;

  static DnaVisibility fromName(Object? value) => switch (value) {
    'public' => public,
    'matches' => matches,
    _ => private,
  };
}

enum DnaDiversityTier {
  focused,
  balanced,
  eclectic;

  static DnaDiversityTier fromName(Object? value) => switch (value) {
    'eclectic' => eclectic,
    'balanced' => balanced,
    _ => focused,
  };
}

class DnaFamily {
  const DnaFamily({
    required this.key,
    required this.share,
    required this.percent,
    this.artists = const [],
  });

  final String key;

  /// 0..1, exact share used for charts.
  final double share;

  /// Rounded so all families add up to 100.
  final int percent;

  /// Top artists behind this family (Spotify), strongest first.
  final List<String> artists;
}

class DnaSubgenre {
  const DnaSubgenre({
    required this.key,
    required this.family,
    required this.share,
    required this.percent,
  });

  final String key;
  final String family;
  final double share;
  final int percent;
}

class DnaSources {
  const DnaSources({
    this.spotify = false,
    this.manual = false,
    this.artists = 0,
    this.artistsClassified = 0,
    this.tracks = 0,
    this.manualGenres = 0,
  });

  final bool spotify;
  final bool manual;
  final int artists;
  final int artistsClassified;
  final int tracks;
  final int manualGenres;
}

class MusicalDna {
  const MusicalDna({
    required this.families,
    required this.subgenres,
    required this.diversityScore,
    required this.diversityTier,
    required this.sources,
    this.capturedOn,
    this.artists = const [],
  });

  /// The user's Spotify top artists behind this snapshot, ranked (owner only;
  /// the server strips it for anyone else).
  final List<String> artists;

  final List<DnaFamily> families;
  final List<DnaSubgenre> subgenres;

  /// 0..100: how spread the taste is across families and subgenres.
  final int diversityScore;
  final DnaDiversityTier diversityTier;
  final DnaSources sources;
  final DateTime? capturedOn;

  bool get isEmpty => families.isEmpty;

  List<DnaSubgenre> subgenresOf(String family) =>
      subgenres.where((s) => s.family == family).toList(growable: false);

  /// Parses a stored snapshot. Malformed entries are skipped; a DNA without
  /// any family is returned as null (nothing to show, nothing invented).
  static MusicalDna? fromJson(Object? raw, {DateTime? capturedOn}) {
    if (raw is! Map) return null;
    double share(Object? v) =>
        v is num && v.isFinite ? v.toDouble().clamp(0, 1).toDouble() : 0;
    int percent(Object? v) => v is num ? v.round().clamp(0, 100) : 0;
    int count(Object? v) => v is num ? v.round().clamp(0, 1 << 20) : 0;

    final families = <DnaFamily>[
      for (final f in (raw['families'] is List ? raw['families'] as List : []))
        if (f is Map && f['key'] is String)
          DnaFamily(
            key: f['key'] as String,
            share: share(f['share']),
            percent: percent(f['percent']),
            artists: f['artists'] is List
                ? (f['artists'] as List).whereType<String>().toList()
                : const [],
          ),
    ];
    if (families.isEmpty) return null;
    final subgenres = <DnaSubgenre>[
      for (final s
          in (raw['subgenres'] is List ? raw['subgenres'] as List : []))
        if (s is Map && s['key'] is String && s['family'] is String)
          DnaSubgenre(
            key: s['key'] as String,
            family: s['family'] as String,
            share: share(s['share']),
            percent: percent(s['percent']),
          ),
    ];
    final diversity = raw['diversity'] is Map ? raw['diversity'] as Map : {};
    final sources = raw['sources'] is Map ? raw['sources'] as Map : {};
    return MusicalDna(
      families: families,
      subgenres: subgenres,
      diversityScore: percent(diversity['score']),
      diversityTier: DnaDiversityTier.fromName(diversity['tier']),
      sources: DnaSources(
        spotify: sources['spotify'] == true,
        manual: sources['manual'] == true,
        artists: count(sources['artists']),
        artistsClassified: count(sources['artists_classified']),
        tracks: count(sources['tracks']),
        manualGenres: count(sources['manual_genres']),
      ),
      capturedOn: capturedOn,
      artists: [
        for (final a in (raw['artists'] is List ? raw['artists'] as List : []))
          if (a is Map &&
              a['name'] is String &&
              (a['name'] as String).isNotEmpty)
            a['name'] as String,
      ],
    );
  }
}

/// One family's change between two snapshots, in percentage points.
class DnaShift {
  const DnaShift({required this.family, required this.from, required this.to});

  final String family;
  final int from;
  final int to;
  int get delta => to - from;
}

/// How the DNA changed from [older] to [newer]: families whose share moved
/// by at least [minPoints], biggest movement first.
List<DnaShift> dnaShifts(
  MusicalDna older,
  MusicalDna newer, {
  int minPoints = 3,
}) {
  final before = {for (final f in older.families) f.key: f.percent};
  final after = {for (final f in newer.families) f.key: f.percent};
  final shifts = [
    for (final key in {...before.keys, ...after.keys})
      DnaShift(family: key, from: before[key] ?? 0, to: after[key] ?? 0),
  ].where((s) => s.delta.abs() >= minPoints).toList();
  shifts.sort((a, b) {
    final byDelta = b.delta.abs().compareTo(a.delta.abs());
    return byDelta != 0 ? byDelta : a.family.compareTo(b.family);
  });
  return shifts;
}

/// Picks up to [count] snapshots spread across the history (oldest first),
/// always including the newest, for the evolution timeline.
List<MusicalDna> sampleDnaHistory(
  List<MusicalDna> newestFirst, {
  int count = 6,
}) {
  if (newestFirst.length <= count) return newestFirst.reversed.toList();
  final oldestFirst = newestFirst.reversed.toList();
  final step = (oldestFirst.length - 1) / (count - 1);
  return [for (var i = 0; i < count; i++) oldestFirst[(i * step).round()]];
}
