/// Automatic circle suggestions (docs/circles.md §3). Pure.
///
/// VIBRA proposes a small group to ONE user: people already on their Same
/// Frequency list (mutual consent to musical matching) who share a genre
/// family, a specific subgenre or an artist with them. Nothing happens until
/// the user creates the circle; then each person receives an invitation they
/// can accept or decline. Nobody is ever added automatically.
library;

import '../entities/musical_dna.dart';
import '../entities/same_frequency.dart';

enum SuggestionBasis { genre, artist }

class CircleSuggestion {
  const CircleSuggestion({
    required this.basis,
    required this.key,
    required this.people,
  });

  final SuggestionBasis basis;

  /// Genre key (family or subgenre) or artist name.
  final String key;

  /// People who would be invited (the user is the fifth member, etc.).
  final List<FrequencyCandidate> people;
}

/// Minimum affinity for a suggested circle member.
const int circleMinAffinity = 65;

List<CircleSuggestion> suggestCircles(
  List<FrequencyCandidate> candidates,
  MusicalDna? dna, {
  int maxSuggestions = 3,
  int peoplePerCircle = 4,
  int maxCirclesPerPerson = 2,
}) {
  final pool =
      candidates.where((c) => c.compatibility >= circleMinAffinity).toList()
        ..sort((a, b) {
          final byScore = b.compatibility.compareTo(a.compatibility);
          return byScore != 0 ? byScore : a.userId.compareTo(b.userId);
        });
  if (pool.length < 2) return const [];

  // Themes in order of how much they define the user: shared artists first
  // (most specific), then strong subgenres, then main families.
  final themes =
      <(SuggestionBasis, String, bool Function(FrequencyCandidate))>[];
  final artistCounts = <String, int>{};
  for (final c in pool) {
    for (final a in c.affinity.sharedArtists) {
      artistCounts[a] = (artistCounts[a] ?? 0) + 1;
    }
  }
  final artists = artistCounts.entries.where((e) => e.value >= 2).toList()
    ..sort((a, b) {
      final byCount = b.value.compareTo(a.value);
      return byCount != 0 ? byCount : a.key.compareTo(b.key);
    });
  for (final a in artists) {
    themes.add((
      SuggestionBasis.artist,
      a.key,
      (c) => c.affinity.sharedArtists.contains(a.key),
    ));
  }
  for (final s in dna?.subgenres ?? const []) {
    if (s.key == s.family || s.share < 0.15) continue;
    themes.add((
      SuggestionBasis.genre,
      s.key,
      (c) => c.affinity.sharedSubgenres.contains(s.key),
    ));
  }
  for (final f in (dna?.families ?? const []).take(3)) {
    themes.add((
      SuggestionBasis.genre,
      f.key,
      (c) => c.affinity.sharedFamilies.contains(f.key),
    ));
  }
  if (dna == null) {
    // Without a DNA, fall back to the families people share with the user.
    final families = <String>{
      for (final c in pool) ...c.affinity.sharedFamilies.take(1),
    };
    for (final f in families) {
      themes.add((
        SuggestionBasis.genre,
        f,
        (c) => c.affinity.sharedFamilies.contains(f),
      ));
    }
  }

  final used = <String, int>{};
  final out = <CircleSuggestion>[];
  final seenGroups = <String>{};
  for (final (basis, key, matches) in themes) {
    final people = pool
        .where((c) => matches(c) && (used[c.userId] ?? 0) < maxCirclesPerPerson)
        .take(peoplePerCircle)
        .toList();
    if (people.length < 2) continue;
    final signature = (people.map((p) => p.userId).toList()..sort()).join(',');
    if (!seenGroups.add(signature)) continue;
    for (final p in people) {
      used[p.userId] = (used[p.userId] ?? 0) + 1;
    }
    out.add(CircleSuggestion(basis: basis, key: key, people: people));
    if (out.length >= maxSuggestions) break;
  }
  return out;
}
