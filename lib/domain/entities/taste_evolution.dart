import 'musical_dna.dart';

/// Taste Evolution (docs/taste-evolution.md). Every comparison is computed
/// from two real Musical DNA snapshots; nothing is estimated or back-filled.
enum TastePeriod {
  month(30),
  threeMonths(90),
  sixMonths(180),
  year(365);

  const TastePeriod(this.days);
  final int days;
}

/// A community joined during the period (real join date).
class JoinedCommunity {
  const JoinedCommunity({
    required this.id,
    required this.name,
    required this.joinedAt,
    this.genreFamily,
  });
  final String id;
  final String name;
  final String? genreFamily;
  final DateTime joinedAt;
}

class TimelinePoint {
  const TimelinePoint(this.capturedOn, this.families);
  final DateTime capturedOn;
  final List<DnaFamily> families;
}

/// An artist moving up into my favourites.
class EmergingArtist {
  const EmergingArtist({
    required this.name,
    required this.rank,
    this.previousRank,
  });
  final String name;

  /// 1-based rank now.
  final int rank;

  /// 1-based rank in the baseline; null when absent then.
  final int? previousRank;

  bool get isNew => previousRank == null;
}

class FamilyChange {
  const FamilyChange({
    required this.key,
    required this.before,
    required this.now,
  });
  final String key;
  final int before;
  final int now;
  int get delta => now - before;
}

class TasteEvolution {
  const TasteEvolution({
    required this.tracking,
    required this.days,
    required this.snapshotCount,
    this.oldestOn,
    this.current,
    this.baseline,
    this.fullPeriod = false,
    this.timeline = const [],
    this.communities = const [],
  });

  /// Historical tracking is on (privacy setting).
  final bool tracking;
  final int days;
  final int snapshotCount;
  final DateTime? oldestOn;
  final MusicalDna? current;

  /// The snapshot compared with; may be newer than [days] ago when history
  /// is shorter ([fullPeriod] false).
  final MusicalDna? baseline;
  final bool fullPeriod;
  final List<TimelinePoint> timeline;
  final List<JoinedCommunity> communities;

  bool get canCompare => current != null && baseline != null;

  /// Subgenres present now (≥ 3%) that were not in the baseline at all.
  List<DnaSubgenre> get newGenres {
    if (!canCompare) return const [];
    final before = {for (final s in baseline!.subgenres) s.key};
    return [
      for (final s in current!.subgenres)
        if (s.percent >= 3 && !before.contains(s.key)) s,
    ];
  }

  /// Top-10 artists now that are new to the list or rose 5+ places.
  List<EmergingArtist> get emergingArtists {
    if (!canCompare) return const [];
    final before = {
      for (var i = 0; i < baseline!.artists.length; i++)
        baseline!.artists[i].toLowerCase(): i + 1,
    };
    final out = <EmergingArtist>[];
    final now = current!.artists.take(10).toList();
    for (var i = 0; i < now.length; i++) {
      final prev = before[now[i].toLowerCase()];
      if (prev == null || prev - (i + 1) >= 5) {
        out.add(EmergingArtist(name: now[i], rank: i + 1, previousRank: prev));
      }
    }
    return out;
  }

  /// Every family in either snapshot, then vs now, biggest now first.
  List<FamilyChange> get distribution {
    if (!canCompare) return const [];
    final before = {for (final f in baseline!.families) f.key: f.percent};
    final now = {for (final f in current!.families) f.key: f.percent};
    final list =
        [
          for (final k in {...now.keys, ...before.keys})
            FamilyChange(key: k, before: before[k] ?? 0, now: now[k] ?? 0),
        ]..sort((a, b) {
          final c = b.now.compareTo(a.now);
          return c != 0 ? c : b.before.compareTo(a.before);
        });
    return list;
  }

  /// Families that mattered then (≥ 10%) and fell to half or less.
  List<FamilyChange> get previousGenres => [
    for (final f in distribution)
      if (f.before >= 10 && f.now * 2 <= f.before) f,
  ];

  /// Baseline top-5 artists no longer in the current top 15.
  List<String> get previousArtists {
    if (!canCompare) return const [];
    final now = {for (final a in current!.artists.take(15)) a.toLowerCase()};
    return [
      for (final a in baseline!.artists.take(5))
        if (!now.contains(a.toLowerCase())) a,
    ];
  }

  /// How much the family mix moved, in percentage points (0..100).
  int get changePoints {
    if (!canCompare) return 0;
    final total = distribution.fold<int>(0, (s, f) => s + f.delta.abs());
    return (total / 2).round();
  }

  /// "Evolved" from 10 points of change; otherwise "steady".
  bool get evolved => changePoints >= 10 || newGenres.length >= 2;

  static TasteEvolution fromJson(Map<String, dynamic> r) {
    MusicalDna? dna(Object? raw) => raw is Map
        ? MusicalDna.fromJson(
            raw['dna'],
            capturedOn: DateTime.tryParse('${raw['captured_on']}'),
          )
        : null;
    final baseline = r['baseline'];
    return TasteEvolution(
      tracking: r['tracking'] != false,
      days: (r['days'] as num?)?.toInt() ?? 90,
      snapshotCount: (r['snapshot_count'] as num?)?.toInt() ?? 0,
      oldestOn: DateTime.tryParse('${r['oldest_on']}'),
      current: dna(r['current']),
      baseline: dna(baseline),
      fullPeriod: baseline is Map && baseline['full_period'] == true,
      timeline: [
        for (final p in (r['timeline'] as List? ?? const []))
          if (p is Map && DateTime.tryParse('${p['captured_on']}') != null)
            if (MusicalDna.fromJson({'families': p['families']}) case final d?)
              TimelinePoint(DateTime.parse('${p['captured_on']}'), d.families),
      ],
      communities: [
        for (final c in (r['communities'] as List? ?? const []))
          if (c is Map &&
              c['id'] is String &&
              c['name'] is String &&
              DateTime.tryParse('${c['joined_at']}') != null)
            JoinedCommunity(
              id: c['id'] as String,
              name: c['name'] as String,
              genreFamily: c['genre_family'] as String?,
              joinedAt: DateTime.parse('${c['joined_at']}'),
            ),
      ],
    );
  }
}
