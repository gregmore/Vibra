/// Risultato del calcolo di compatibilità tra due utenti.
class CompatibilityResult {
  const CompatibilityResult({
    required this.percentage,
    required this.sharedArtistsPercentage,
    required this.sharedGenresPercentage,
  });

  final double percentage;
  final double sharedArtistsPercentage;
  final double sharedGenresPercentage;
}

/// Risultato del punteggio di raccomandazione di un evento.
class EventRecommendationScore {
  const EventRecommendationScore({
    required this.totalScore,
    required this.artistMatchScore,
    required this.genreMatchScore,
    required this.proximityScore,
    required this.popularityScore,
  });

  final double totalScore;
  final double artistMatchScore;
  final double genreMatchScore;
  final double proximityScore;
  final double popularityScore;
}
