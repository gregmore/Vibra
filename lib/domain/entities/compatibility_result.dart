/// Risultato del calcolo di compatibilità tra due utenti.
class CompatibilityResult {
  const CompatibilityResult({
    required this.percentage,
    required this.artistScore,
    required this.genreScore,
    required this.nicheBonus,
    this.sharedArtistNames = const [],
    this.sharedGenreNames = const [],
  });

  /// Score finale di compatibilità (0–100).
  final double percentage;

  /// Contributo degli artisti in comune, pesato per posizione (0–100).
  final double artistScore;

  /// Contributo dei generi in comune, pesato per weight (0–100).
  final double genreScore;

  /// Bonus per generi di nicchia condivisi (0–100).
  final double nicheBonus;

  /// Nomi degli artisti in comune, ordinati per rilevanza.
  final List<String> sharedArtistNames;

  /// Nomi dei generi in comune, ordinati per peso medio.
  final List<String> sharedGenreNames;
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
