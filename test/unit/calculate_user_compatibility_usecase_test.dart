import 'package:flutter_test/flutter_test.dart';
import 'package:vibra/domain/entities/music_profile.dart';
import 'package:vibra/domain/usecases/calculate_user_compatibility_usecase.dart';

void main() {
  group('CalculateUserCompatibilityUseCase', () {
    const usecase = CalculateUserCompatibilityUseCase();

    test('returns 0 when no overlap', () {
      final left = MusicProfile(
        id: 'm1',
        userId: 'u1',
        topArtists: const [
          MusicArtistPreference(id: 'a1', name: 'A1', score: 100),
        ],
        topTracks: const [],
        topGenres: const [GenrePreference(genre: 'house', weight: 1)],
        lastSyncedAt: null,
      );

      final right = MusicProfile(
        id: 'm2',
        userId: 'u2',
        topArtists: const [
          MusicArtistPreference(id: 'a2', name: 'A2', score: 100),
        ],
        topTracks: const [],
        topGenres: const [GenrePreference(genre: 'metal', weight: 1)],
        lastSyncedAt: null,
      );

      final result = usecase(left: left, right: right);
      expect(result.percentage, 0);
      expect(result.sharedArtistsPercentage, 0);
      expect(result.sharedGenresPercentage, 0);
    });

    test('artist overlap contributes 60% weight', () {
      final artists = List.generate(
        50,
        (i) => MusicArtistPreference(id: 'a$i', name: 'A$i', score: 100 - i),
      );

      final left = MusicProfile(
        id: 'm1',
        userId: 'u1',
        topArtists: artists,
        topTracks: const [],
        topGenres: const [],
        lastSyncedAt: null,
      );

      final right = MusicProfile(
        id: 'm2',
        userId: 'u2',
        topArtists: artists.take(25).toList(), // 25 in comune
        topTracks: const [],
        topGenres: const [],
        lastSyncedAt: null,
      );

      final result = usecase(left: left, right: right);

      // artisti_in_comune / 50 = 0.5 → 50 * 0.60 = 30
      expect(result.sharedArtistsPercentage, 50);
      expect(result.percentage, 30);
    });

    test('genre overlap uses union of genres as denominator', () {
      final left = MusicProfile(
        id: 'm1',
        userId: 'u1',
        topArtists: const [],
        topTracks: const [],
        topGenres: const [
          GenrePreference(genre: 'house', weight: 1),
          GenrePreference(genre: 'electronic', weight: 1),
        ],
        lastSyncedAt: null,
      );

      final right = MusicProfile(
        id: 'm2',
        userId: 'u2',
        topArtists: const [],
        topTracks: const [],
        topGenres: const [
          GenrePreference(genre: 'house', weight: 1),
          GenrePreference(genre: 'indie', weight: 1),
        ],
        lastSyncedAt: null,
      );

      // union = {house,electronic,indie} => 3
      // sharedGenres = {house} => 1 => 33.33% * 0.40 = 13.33
      final result = usecase(left: left, right: right);
      expect(result.sharedGenresPercentage, closeTo(33.33, 0.01));
      expect(result.percentage, closeTo(13.33, 0.02));
    });
  });
}
