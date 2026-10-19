import 'dart:math' as math;

import '../../core/constants/app_constants.dart';
import '../entities/compatibility_result.dart';
import '../entities/music_profile.dart';

/// Algoritmo di compatibilità utenti v2.
///
/// Utilizza tre componenti pesate:
///
/// 1. **Artist Score** (cosine similarity pesata per posizione):
///    Tiene conto non solo degli artisti in comune, ma anche della loro
///    posizione nei top 50 di ciascun utente.
///
/// 2. **Genre Score** (cosine similarity pesata per weight):
///    Utilizza i weight dei generi (0.0–1.0, normalizzati sulla frequenza
///    tra gli artisti) per calcolare una similarità vettoriale reale.
///
/// 3. **Niche Bonus** (premio per generi rari condivisi):
///    Generi con peso basso in entrambi i profili (= di nicchia) ricevono
///    un bonus maggiore rispetto a generi generici come "pop".
///
/// Formula finale:
///   compatibility = artistScore × 0.50 + genreScore × 0.35 + nicheBonus × 0.15
class CalculateUserCompatibilityUseCase {
  const CalculateUserCompatibilityUseCase();

  CompatibilityResult call({
    required MusicProfile left,
    required MusicProfile right,
  }) {
    // ── 1. Artist Score (Cosine Similarity pesata per posizione) ────
    final artistResult = _calculateArtistScore(left, right);

    // ── 2. Genre Score (Cosine Similarity pesata per weight) ────────
    final genreResult = _calculateGenreScore(left, right);

    // ── 3. Niche Bonus ─────────────────────────────────────────────
    final nicheBonus = _calculateNicheBonus(
      left,
      right,
      genreResult.sharedGenres,
    );

    // ── Score finale ───────────────────────────────────────────────
    final total =
        (artistResult.score * AppConstants.weightUserArtists) +
        (genreResult.score * AppConstants.weightUserGenres) +
        (nicheBonus * AppConstants.weightUserNicheBonus);

    return CompatibilityResult(
      percentage: _round(total.clamp(0, 100)),
      artistScore: _round(artistResult.score),
      genreScore: _round(genreResult.score),
      nicheBonus: _round(nicheBonus),
      sharedArtistNames: artistResult.sharedNames,
      sharedGenreNames: genreResult.sharedNames,
    );
  }

  // ── Artisti: Cosine Similarity pesata ──────────────────────────────

  _ArtistScoreResult _calculateArtistScore(
    MusicProfile left,
    MusicProfile right,
  ) {
    if (left.topArtists.isEmpty || right.topArtists.isEmpty) {
      return const _ArtistScoreResult(score: 0, sharedNames: []);
    }

    // Costruisci mappa id → score per entrambi
    final leftScores = <String, double>{
      for (final a in left.topArtists) a.id: a.score.toDouble(),
    };
    final rightScores = <String, double>{
      for (final a in right.topArtists) a.id: a.score.toDouble(),
    };
    final rightNameMap = <String, String>{
      for (final a in right.topArtists) a.id: a.name,
    };
    final leftNameMap = <String, String>{
      for (final a in left.topArtists) a.id: a.name,
    };

    // Artisti in comune
    final sharedIds = leftScores.keys.toSet().intersection(
      rightScores.keys.toSet(),
    );

    if (sharedIds.isEmpty) {
      return const _ArtistScoreResult(score: 0, sharedNames: []);
    }

    // Prodotto scalare per gli artisti in comune
    double dotProduct = 0;
    for (final id in sharedIds) {
      dotProduct += leftScores[id]! * rightScores[id]!;
    }

    // Magnitudine vettori completi
    double leftMagnitude = 0;
    for (final score in leftScores.values) {
      leftMagnitude += score * score;
    }
    leftMagnitude = math.sqrt(leftMagnitude);

    double rightMagnitude = 0;
    for (final score in rightScores.values) {
      rightMagnitude += score * score;
    }
    rightMagnitude = math.sqrt(rightMagnitude);

    final denominator = leftMagnitude * rightMagnitude;
    final cosineSimilarity = denominator == 0 ? 0.0 : dotProduct / denominator;

    // Nomi degli artisti in comune, ordinati per media score (più rilevanti prima)
    final sharedNames = sharedIds.toList()
      ..sort((a, b) {
        final avgA = (leftScores[a]! + rightScores[a]!) / 2;
        final avgB = (leftScores[b]! + rightScores[b]!) / 2;
        return avgB.compareTo(avgA);
      });

    final names = sharedNames
        .map((id) {
          return leftNameMap[id] ?? rightNameMap[id] ?? id;
        })
        .toList(growable: false);

    return _ArtistScoreResult(
      score: cosineSimilarity * 100,
      sharedNames: names,
    );
  }

  // ── Generi: Cosine Similarity pesata ──────────────────────────────

  _GenreScoreResult _calculateGenreScore(
    MusicProfile left,
    MusicProfile right,
  ) {
    if (left.topGenres.isEmpty || right.topGenres.isEmpty) {
      return const _GenreScoreResult(
        score: 0,
        sharedNames: [],
        sharedGenres: {},
      );
    }

    // Costruisci mappa genere → weight per entrambi
    final leftWeights = <String, double>{
      for (final g in left.topGenres) g.genre.toLowerCase(): g.weight,
    };
    final rightWeights = <String, double>{
      for (final g in right.topGenres) g.genre.toLowerCase(): g.weight,
    };

    // Generi in comune
    final sharedGenres = leftWeights.keys.toSet().intersection(
      rightWeights.keys.toSet(),
    );

    if (sharedGenres.isEmpty) {
      return const _GenreScoreResult(
        score: 0,
        sharedNames: [],
        sharedGenres: {},
      );
    }

    // Prodotto scalare per generi in comune
    double dotProduct = 0;
    for (final genre in sharedGenres) {
      dotProduct += leftWeights[genre]! * rightWeights[genre]!;
    }

    // Magnitudine vettori completi
    double leftMagnitude = 0;
    for (final w in leftWeights.values) {
      leftMagnitude += w * w;
    }
    leftMagnitude = math.sqrt(leftMagnitude);

    double rightMagnitude = 0;
    for (final w in rightWeights.values) {
      rightMagnitude += w * w;
    }
    rightMagnitude = math.sqrt(rightMagnitude);

    final denominator = leftMagnitude * rightMagnitude;
    final cosineSimilarity = denominator == 0 ? 0.0 : dotProduct / denominator;

    // Nomi dei generi in comune, ordinati per media peso
    final sharedNamesList = sharedGenres.toList()
      ..sort((a, b) {
        final avgA = (leftWeights[a]! + rightWeights[a]!) / 2;
        final avgB = (leftWeights[b]! + rightWeights[b]!) / 2;
        return avgB.compareTo(avgA);
      });

    // Mappa genri condivisi con pesi per il niche bonus
    final sharedWeightsMap = <String, ({double leftW, double rightW})>{
      for (final g in sharedGenres)
        g: (leftW: leftWeights[g]!, rightW: rightWeights[g]!),
    };

    return _GenreScoreResult(
      score: cosineSimilarity * 100,
      sharedNames: sharedNamesList,
      sharedGenres: sharedWeightsMap,
    );
  }

  // ── Niche Bonus ───────────────────────────────────────────────────

  double _calculateNicheBonus(
    MusicProfile left,
    MusicProfile right,
    Map<String, ({double leftW, double rightW})> sharedGenres,
  ) {
    if (sharedGenres.isEmpty) return 0;

    // Generi con peso medio basso (= di nicchia) ricevono più bonus.
    // Formula: per ogni genere condiviso, bonus = (1 - avgWeight) × min(wA, wB)
    // Questo premia generi rari (avgWeight basso) che sono presenti in entrambi.
    double totalBonus = 0;
    double maxPossible = 0;

    for (final entry in sharedGenres.entries) {
      final avgWeight = (entry.value.leftW + entry.value.rightW) / 2;
      final nicheWeight =
          1.0 - avgWeight; // Più il genere è di nicchia, più alto
      final presence = math.min(entry.value.leftW, entry.value.rightW);

      totalBonus += nicheWeight * presence;
      maxPossible += 1.0; // Max teorico: nicheWeight=1.0 × presence=1.0
    }

    if (maxPossible == 0) return 0;

    return (totalBonus / maxPossible) * 100;
  }

  // ── Utilità ───────────────────────────────────────────────────────

  static double _round(double value) {
    return double.parse(value.toStringAsFixed(2));
  }
}

// ── Tipi di supporto interni ─────────────────────────────────────────

class _ArtistScoreResult {
  const _ArtistScoreResult({required this.score, required this.sharedNames});
  final double score;
  final List<String> sharedNames;
}

class _GenreScoreResult {
  const _GenreScoreResult({
    required this.score,
    required this.sharedNames,
    required this.sharedGenres,
  });
  final double score;
  final List<String> sharedNames;
  final Map<String, ({double leftW, double rightW})> sharedGenres;
}
