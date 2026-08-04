import '../entities/compatibility_result.dart';

/// Algoritmo di raccomandazione eventi descritto nel prompt:
/// score_finale = (
///   artist_match_score * 0.50 +
///   genre_match_score  * 0.25 +
///   proximity_score    * 0.15 +
///   popularity_score   * 0.10
/// )
class CalculateEventRecommendationScoreUseCase {
  const CalculateEventRecommendationScoreUseCase();

  EventRecommendationScore call({
    required double artistMatchScore,
    required double genreMatchScore,
    required double distanceKm,
    required double popularityScore,
  }) {
    final normalizedArtist = _clamp(artistMatchScore);
    final normalizedGenre = _clamp(genreMatchScore);
    final normalizedPopularity = _clamp(popularityScore);
    final proximity = _calculateProximityScore(distanceKm);

    final total =
        (normalizedArtist * 0.50) +
        (normalizedGenre * 0.25) +
        (proximity * 0.15) +
        (normalizedPopularity * 0.10);

    return EventRecommendationScore(
      totalScore: double.parse(total.toStringAsFixed(2)),
      artistMatchScore: normalizedArtist,
      genreMatchScore: normalizedGenre,
      proximityScore: proximity,
      popularityScore: normalizedPopularity,
    );
  }

  double _calculateProximityScore(double distanceKm) {
    if (distanceKm <= 25) return 100;
    if (distanceKm >= 250) return 0;

    final slope = 100 / (250 - 25);
    final score = 100 - ((distanceKm - 25) * slope);
    return double.parse(_clamp(score).toStringAsFixed(2));
  }

  double _clamp(double value) {
    if (value < 0) return 0;
    if (value > 100) return 100;
    return value;
  }
}
