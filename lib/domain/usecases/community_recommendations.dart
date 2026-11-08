/// Community recommendations from the user's Musical DNA
/// (docs/communities.md §4). Pure and deterministic.
///
/// * Artist communities: the artist is in the user's Spotify top artists.
/// * Genre communities: the community's subgenre (or, for a family-wide
///   community, the family) holds a real share of the user's DNA.
/// Every recommendation carries the data point that justifies it.
library;

import 'dart:math' as math;

import '../entities/community.dart';
import '../entities/musical_dna.dart';

sealed class CommunityReason {
  const CommunityReason();
}

/// "Travis Scott is one of your top artists."
class TopArtistReason extends CommunityReason {
  const TopArtistReason(this.artist);
  final String artist;
}

/// "Trap is 25% of your Musical DNA." (subgenre or family key)
class GenreShareReason extends CommunityReason {
  const GenreShareReason(this.genreKey, this.percent);
  final String genreKey;
  final int percent;
}

class CommunityRecommendation {
  const CommunityRecommendation(this.community, this.reason, this.score);
  final Community community;
  final CommunityReason reason;
  final double score;
}

String _norm(String s) => s.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '');

/// Minimum DNA share for a genre community to be suggested.
const double minGenreShare = 0.08;

List<CommunityRecommendation> recommendCommunities(
  List<Community> communities,
  MusicalDna? dna, {
  int limit = 6,
  int maxPerFamily = 2,
}) {
  if (dna == null || dna.isEmpty) return const [];
  final artistRank = <String, int>{};
  for (var i = 0; i < dna.artists.length; i++) {
    artistRank.putIfAbsent(_norm(dna.artists[i]), () => i);
  }
  final familyShare = {for (final f in dna.families) f.key: f};
  final subShare = {for (final s in dna.subgenres) s.key: s};

  final scored = <CommunityRecommendation>[];
  for (final c in communities) {
    if (c.isMember) continue;
    final popularity = 0.02 * math.log(1 + c.memberCount) / math.ln10;
    switch (c.kind) {
      case CommunityKind.artist:
        final rank = c.artistName == null
            ? null
            : artistRank[_norm(c.artistName!)];
        if (rank != null) {
          scored.add(
            CommunityRecommendation(
              c,
              TopArtistReason(c.artistName!),
              1.0 - rank * 0.01 + popularity,
            ),
          );
        }
      case CommunityKind.genre:
        final key = c.genreKey, family = c.genreFamily;
        if (key == null || family == null) continue;
        if (key == family) {
          final f = familyShare[family];
          if (f != null && f.share >= minGenreShare) {
            scored.add(
              CommunityRecommendation(
                c,
                GenreShareReason(family, f.percent),
                f.share + popularity,
              ),
            );
          }
        } else {
          final s = subShare[key];
          if (s != null && s.share >= minGenreShare) {
            // A specific scene the user really listens to ranks a little above
            // the broad family community of the same weight.
            scored.add(
              CommunityRecommendation(
                c,
                GenreShareReason(key, s.percent),
                s.share * 1.15 + popularity,
              ),
            );
          }
        }
      case CommunityKind.interest:
        break;
    }
  }
  scored.sort((a, b) {
    final byScore = b.score.compareTo(a.score);
    return byScore != 0 ? byScore : a.community.id.compareTo(b.community.id);
  });
  // Diversity: at most [maxPerFamily] genre communities from one family.
  final perFamily = <String, int>{};
  final out = <CommunityRecommendation>[];
  for (final r in scored) {
    final family = r.community.genreFamily;
    if (family != null) {
      if ((perFamily[family] ?? 0) >= maxPerFamily) continue;
      perFamily[family] = (perFamily[family] ?? 0) + 1;
    }
    out.add(r);
    if (out.length >= limit) break;
  }
  return out;
}

/// Top artists (up to [limit]) with no community yet: "Start the
/// community" suggestions.
List<String> artistsWithoutCommunity(
  List<Community> communities,
  MusicalDna? dna, {
  int limit = 2,
}) {
  if (dna == null) return const [];
  final existing = {
    for (final c in communities)
      if (c.kind == CommunityKind.artist && c.artistName != null)
        _norm(c.artistName!),
  };
  return dna.artists
      .take(10)
      .where((a) => !existing.contains(_norm(a)))
      .take(limit)
      .toList(growable: false);
}
