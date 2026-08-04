import 'package:flutter_test/flutter_test.dart';
import 'package:vibra/domain/usecases/calculate_event_recommendation_score_usecase.dart';

void main() {
  group('CalculateEventRecommendationScoreUseCase', () {
    const usecase = CalculateEventRecommendationScoreUseCase();

    test('proximity: <25km => 100', () {
      final result = usecase(
        artistMatchScore: 80,
        genreMatchScore: 40,
        distanceKm: 10,
        popularityScore: 20,
      );

      expect(result.proximityScore, 100);
    });

    test('proximity: >=250km => 0', () {
      final result = usecase(
        artistMatchScore: 80,
        genreMatchScore: 40,
        distanceKm: 250,
        popularityScore: 20,
      );

      expect(result.proximityScore, 0);
    });

    test('clamp input scores to 0..100', () {
      final result = usecase(
        artistMatchScore: 999,
        genreMatchScore: -10,
        distanceKm: 25,
        popularityScore: 500,
      );

      expect(result.artistMatchScore, 100);
      expect(result.genreMatchScore, 0);
      expect(result.popularityScore, 100);
      expect(result.proximityScore, 100);
    });

    test('computes weighted total correctly (2 decimals)', () {
      // artist=80 (0.5), genre=40 (0.25), proximity=100 (0.15), popularity=20 (0.1)
      // total = 40 + 10 + 15 + 2 = 67
      final result = usecase(
        artistMatchScore: 80,
        genreMatchScore: 40,
        distanceKm: 10,
        popularityScore: 20,
      );

      expect(result.totalScore, 67);
    });
  });
}

