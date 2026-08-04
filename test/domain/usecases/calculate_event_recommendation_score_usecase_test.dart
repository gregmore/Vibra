import 'package:flutter_test/flutter_test.dart';
import 'package:vibra/domain/usecases/calculate_event_recommendation_score_usecase.dart';

void main() {
  group('CalculateEventRecommendationScoreUseCase', () {
    const usecase = CalculateEventRecommendationScoreUseCase();

    test('calcola il punteggio massimo se tutti i parametri sono perfetti', () {
      final result = usecase.call(
        artistMatchScore: 100,
        genreMatchScore: 100,
        distanceKm: 10, // <= 25km (proximity = 100)
        popularityScore: 100,
      );

      expect(result.totalScore, 100.0);
      expect(result.artistMatchScore, 100.0);
      expect(result.genreMatchScore, 100.0);
      expect(result.proximityScore, 100.0);
      expect(result.popularityScore, 100.0);
    });

    test('calcola il punteggio minimo se tutti i parametri sono pessimi', () {
      final result = usecase.call(
        artistMatchScore: 0,
        genreMatchScore: 0,
        distanceKm: 300, // >= 250km (proximity = 0)
        popularityScore: 0,
      );

      expect(result.totalScore, 0.0);
      expect(result.artistMatchScore, 0.0);
      expect(result.genreMatchScore, 0.0);
      expect(result.proximityScore, 0.0);
      expect(result.popularityScore, 0.0);
    });

    test('restituisce risultati coerenti con valori intermedi', () {
      // artist: 50 * 0.5 = 25
      // genre: 40 * 0.25 = 10
      // distance: 137.5km (metà tra 25 e 250) -> proximity 50 * 0.15 = 7.5
      // popularity: 80 * 0.10 = 8
      // Total = 25 + 10 + 7.5 + 8 = 50.5
      final result = usecase.call(
        artistMatchScore: 50,
        genreMatchScore: 40,
        distanceKm: 137.5,
        popularityScore: 80,
      );

      expect(result.totalScore, 50.5);
      expect(result.proximityScore, 50.0);
    });

    test('la prossimità scala linearmente tra 25km e 250km', () {
      // 25km = 100 score
      // 250km = 0 score
      // Range: 225km
      // Decrease per km = 100 / 225 = 0.444

      final result1 = usecase.call(
        artistMatchScore: 0,
        genreMatchScore: 0,
        popularityScore: 0,
        distanceKm: 26,
      );
      // 100 - (1 * (100/225)) = 99.56
      expect(result1.proximityScore, 99.56);

      final result2 = usecase.call(
        artistMatchScore: 0,
        genreMatchScore: 0,
        popularityScore: 0,
        distanceKm: 249,
      );
      // 100 - (224 * (100/225)) = 0.44
      expect(result2.proximityScore, 0.44);
    });

    test('valori clampati per input negativi o oltre 100', () {
      final result = usecase.call(
        artistMatchScore: 150, // clamped to 100
        genreMatchScore: -20, // clamped to 0
        distanceKm: -10, // clamped proximity to 100
        popularityScore: 999, // clamped to 100
      );

      expect(result.artistMatchScore, 100.0);
      expect(result.genreMatchScore, 0.0);
      expect(result.proximityScore, 100.0);
      expect(result.popularityScore, 100.0);

      // Total: 100*0.5 + 0 + 100*0.15 + 100*0.10 = 50 + 0 + 15 + 10 = 75.0
      expect(result.totalScore, 75.0);
    });
  });
}
