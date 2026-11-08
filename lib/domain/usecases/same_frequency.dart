/// Same Frequency ranking (docs/same-frequency.md).
///
/// Not a sort by percentage: the server's affinity score is one signal among
/// shared artists, artists both recently discovered, a shared musical
/// direction, shared upcoming events and shared communities. Then:
///   * rotation — people shown recently or many times step back, so the list
///     does not keep returning the same faces;
///   * diversity — a greedy pick that penalises repeating the same main genre
///     family, so the list is not a row of clones.
/// Pure and deterministic for a given `now`.
library;

import 'dart:math' as math;

import '../entities/same_frequency.dart';

/// Weights of the connection strength (sum to 1).
abstract final class FrequencyWeights {
  static const double affinity = 0.50;
  static const double sharedArtists = 0.15;
  static const double discoveries = 0.10;
  static const double direction = 0.10;
  static const double events = 0.10;
  static const double communities = 0.05;
}

/// Connection strength 0..1 from every signal.
double connectionStrength(FrequencyCandidate c) {
  final artists = math.min(c.affinity.sharedArtistCount, 5) / 5;
  final discoveries = math.min(c.sharedDiscoveries.length, 3) / 3;
  final direction = math.min(c.risingFamilies.length, 2) / 2;
  final events = math.min(c.sharedEvents, 2) / 2;
  final communities = math.min(c.sharedCommunities.length, 2) / 2;
  return FrequencyWeights.affinity * (c.compatibility / 100) +
      FrequencyWeights.sharedArtists * artists +
      FrequencyWeights.discoveries * discoveries +
      FrequencyWeights.direction * direction +
      FrequencyWeights.events * events +
      FrequencyWeights.communities * communities;
}

/// Signals beyond the genre score itself.
int extraSignals(FrequencyCandidate c) =>
    (c.affinity.sharedArtistCount > 0 ? 1 : 0) +
    (c.sharedDiscoveries.isNotEmpty ? 1 : 0) +
    (c.risingFamilies.isNotEmpty ? 1 : 0) +
    (c.sharedEvents > 0 ? 1 : 0) +
    (c.sharedCommunities.isNotEmpty ? 1 : 0);

/// "A strong musical connection": high affinity on its own, or moderate
/// affinity backed by at least one more concrete signal.
bool isStrongConnection(FrequencyCandidate c) =>
    c.compatibility >= 65 || (c.compatibility >= 45 && extraSignals(c) >= 1);

/// Rotation factor 0..1. Saved people are never pushed back.
double rotationFactor(FrequencyCandidate c, DateTime now) {
  if (c.saved) return 1;
  var factor = 1.0;
  final last = c.lastShownAt;
  if (last != null) {
    final hours = now.difference(last).inMinutes / 60;
    if (hours < 24) {
      factor *= 0.55;
    } else if (hours < 72) {
      factor *= 0.8;
    }
  }
  // Seen often without any action: step back a little more each time.
  if (c.timesShown >= 3) {
    factor *= math.pow(0.85, math.min(c.timesShown - 2, 5)).toDouble();
  }
  return factor;
}

/// The other person's main family, for diversity ("their sound").
String? primaryFamily(FrequencyCandidate c) {
  if (c.affinity.theirTopFamilies.isNotEmpty) {
    return c.affinity.theirTopFamilies.first;
  }
  return c.affinity.sharedFamilies.isNotEmpty
      ? c.affinity.sharedFamilies.first
      : null;
}

class FrequencyResult {
  const FrequencyResult({required this.people, required this.strongCount});

  /// Ordered for display.
  final List<FrequencyCandidate> people;

  /// How many people have a strong connection (the headline number).
  final int strongCount;
}

/// Ranks [candidates] for display: strong connections only, weighted by
/// every signal, rotated, then diversified. [limit] caps the list.
FrequencyResult rankSameFrequency(
  List<FrequencyCandidate> candidates, {
  required DateTime now,
  int limit = 12,
  double diversityPenalty = 0.12,
}) {
  final strong = candidates.where(isStrongConnection).toList();
  final scored = {
    for (final c in strong)
      c.userId: connectionStrength(c) * rotationFactor(c, now),
  };
  final pool = [...strong];
  final picked = <FrequencyCandidate>[];
  final familyCount = <String, int>{};
  while (pool.isNotEmpty && picked.length < limit) {
    FrequencyCandidate? best;
    var bestValue = double.negativeInfinity;
    for (final c in pool) {
      final family = primaryFamily(c);
      final repeats = family == null ? 0 : familyCount[family] ?? 0;
      final value = scored[c.userId]! - diversityPenalty * repeats;
      if (value > bestValue ||
          (value == bestValue && c.userId.compareTo(best!.userId) < 0)) {
        best = c;
        bestValue = value;
      }
    }
    pool.remove(best);
    picked.add(best!);
    final family = primaryFamily(best);
    if (family != null) familyCount[family] = (familyCount[family] ?? 0) + 1;
  }
  return FrequencyResult(people: picked, strongCount: strong.length);
}
