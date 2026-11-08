/// Music affinity as computed and cached by the server engine
/// (supabase/functions/_shared/music_affinity.ts). The app only renders it:
/// the score and every reason come from `user_matches.details`.
library;

/// Documented bands (docs/music-affinity-engine.md). Musical, not social:
/// a low band is framed as discovery, never as incompatibility.
enum AffinityCategory {
  exceptional,
  veryHigh,
  high,
  moderate,
  low,
  veryLow;

  static AffinityCategory fromScore(int score) {
    if (score >= 90) return exceptional;
    if (score >= 80) return veryHigh;
    if (score >= 65) return high;
    if (score >= 45) return moderate;
    if (score >= 25) return low;
    return veryLow;
  }
}

sealed class AffinityReason {
  const AffinityReason();

  static AffinityReason? fromJson(Object? raw) {
    if (raw is! Map) return null;
    List<String> strings(Object? value) => value is List
        ? value.whereType<String>().toList(growable: false)
        : const [];
    switch (raw['code']) {
      case 'shared_families':
        final families = strings(raw['families']);
        return families.isEmpty ? null : SharedFamiliesReason(families);
      case 'shared_subgenres':
        final subgenres = strings(raw['subgenres']);
        return subgenres.isEmpty ? null : SharedSubgenresReason(subgenres);
      case 'different_subgenres':
        final family = raw['family'];
        return family is String ? DifferentSubgenresReason(family) : null;
      case 'related_families':
        final families = strings(raw['families']);
        return families.length == 2
            ? RelatedFamiliesReason(families[0], families[1])
            : null;
      case 'shared_artists':
        final count = raw['count'];
        return count is num && count > 0
            ? SharedArtistsReason(count.toInt(), strings(raw['artists']))
            : null;
      case 'common_ground':
        final families = strings(raw['families']);
        return families.isEmpty ? null : CommonGroundReason(families);
      case 'diversity':
        final pattern = switch (raw['pattern']) {
          'both_eclectic' => DiversityPattern.bothEclectic,
          'both_focused' => DiversityPattern.bothFocused,
          'contrast' => DiversityPattern.contrast,
          _ => null,
        };
        return pattern == null ? null : DiversityReason(pattern);
      case 'discovery':
        return const DiscoveryReason();
    }
    // Unknown codes from a newer engine are skipped, never guessed.
    return null;
  }
}

class SharedFamiliesReason extends AffinityReason {
  const SharedFamiliesReason(this.families);
  final List<String> families;
}

class SharedSubgenresReason extends AffinityReason {
  const SharedSubgenresReason(this.subgenres);
  final List<String> subgenres;
}

class DifferentSubgenresReason extends AffinityReason {
  const DifferentSubgenresReason(this.family);
  final String family;
}

class RelatedFamiliesReason extends AffinityReason {
  const RelatedFamiliesReason(this.first, this.second);
  final String first;
  final String second;
}

class SharedArtistsReason extends AffinityReason {
  const SharedArtistsReason(this.count, this.artists);
  final int count;
  final List<String> artists;
}

/// Families both listen to, without one being a main sound for both.
class CommonGroundReason extends AffinityReason {
  const CommonGroundReason(this.families);
  final List<String> families;
}

enum DiversityPattern { bothEclectic, bothFocused, contrast }

/// How broad each taste is (never names which side is which).
class DiversityReason extends AffinityReason {
  const DiversityReason(this.pattern);
  final DiversityPattern pattern;
}

class DiscoveryReason extends AffinityReason {
  const DiscoveryReason();
}

class AffinityDetails {
  const AffinityDetails({
    required this.sharedFamilies,
    required this.sharedSubgenres,
    required this.sharedArtists,
    required this.sharedArtistCount,
    required this.theirTopFamilies,
    required this.reasons,
    this.genreScore,
    this.artistScore,
  });

  static const empty = AffinityDetails(
    sharedFamilies: [],
    sharedSubgenres: [],
    sharedArtists: [],
    sharedArtistCount: 0,
    theirTopFamilies: [],
    reasons: [],
  );

  final List<String> sharedFamilies;
  final List<String> sharedSubgenres;
  final List<String> sharedArtists;
  final int sharedArtistCount;

  /// The other person's main families (keys), for the card.
  final List<String> theirTopFamilies;
  final List<AffinityReason> reasons;
  final double? genreScore;
  final double? artistScore;

  bool get hasExplanation => reasons.isNotEmpty;

  /// Parses the server's `details`. Anything malformed degrades to fewer
  /// details, never to invented ones.
  factory AffinityDetails.fromJson(Object? raw, {required String otherUserId}) {
    if (raw is! Map) return empty;
    List<String> strings(Object? value) => value is List
        ? value.whereType<String>().toList(growable: false)
        : const [];
    final topFamilies = raw['top_families'];
    final count = raw['shared_artist_count'];
    double? score(Object? value) =>
        value is num ? value.toDouble().clamp(0.0, 1.0) : null;
    return AffinityDetails(
      sharedFamilies: strings(raw['shared_families']),
      sharedSubgenres: strings(raw['shared_subgenres']),
      sharedArtists: strings(raw['shared_artists']),
      sharedArtistCount: count is num ? count.toInt() : 0,
      theirTopFamilies: topFamilies is Map
          ? strings(topFamilies[otherUserId])
          : const [],
      reasons: [
        if (raw['reasons'] is List)
          for (final reason in raw['reasons'] as List)
            ?AffinityReason.fromJson(reason),
      ],
      genreScore: score(raw['genre']),
      artistScore: score(raw['artist']),
    );
  }
}

/// Discovery diversity: the feed stays ranked by affinity, but every
/// [interval]-th slot goes to the best remaining *related but different*
/// profile (moderate band with a shared or neighbouring family), so the deck
/// is never only clones of the user's own taste. Deterministic; never adds
/// or drops anyone.
List<T> diversifyAffinityFeed<T>(
  List<T> ranked, {
  required int Function(T) score,
  required AffinityDetails? Function(T) details,
  int interval = 5,
}) {
  bool isDiscovery(T item) {
    final s = score(item);
    if (AffinityCategory.fromScore(s) != AffinityCategory.moderate) {
      return false;
    }
    final d = details(item);
    return d != null &&
        d.reasons.any(
          (r) => r is RelatedFamiliesReason || r is DifferentSubgenresReason,
        );
  }

  final remaining = [...ranked];
  final result = <T>[];
  while (remaining.isNotEmpty) {
    final slot = result.length + 1;
    var index = 0;
    if (slot % interval == 0) {
      final discovery = remaining.indexWhere(isDiscovery);
      if (discovery > 0) index = discovery;
    }
    result.add(remaining.removeAt(index));
  }
  return result;
}
