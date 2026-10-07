import 'package:flutter_test/flutter_test.dart';
import 'package:vibra/domain/entities/music_profile.dart';
import 'package:vibra/domain/usecases/calculate_user_compatibility_usecase.dart';

void main() {
  group('CalculateUserCompatibilityUseCase v2', () {
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
      expect(result.artistScore, 0);
      expect(result.genreScore, 0);
      expect(result.nicheBonus, 0);
      expect(result.sharedArtistNames, isEmpty);
      expect(result.sharedGenreNames, isEmpty);
    });

    test('is symmetric: match(A,B) == match(B,A)', () {
      final left = MusicProfile(
        id: 'm1',
        userId: 'u1',
        topArtists: const [
          MusicArtistPreference(id: 'a1', name: 'A1', score: 100),
          MusicArtistPreference(id: 'a2', name: 'A2', score: 90),
          MusicArtistPreference(id: 'a3', name: 'A3', score: 80),
        ],
        topTracks: const [],
        topGenres: const [
          GenrePreference(genre: 'indie rock', weight: 1.0),
          GenrePreference(genre: 'shoegaze', weight: 0.5),
        ],
        lastSyncedAt: null,
      );

      final right = MusicProfile(
        id: 'm2',
        userId: 'u2',
        topArtists: const [
          MusicArtistPreference(id: 'a1', name: 'A1', score: 95),
          MusicArtistPreference(id: 'a4', name: 'A4', score: 85),
          MusicArtistPreference(id: 'a2', name: 'A2', score: 70),
        ],
        topTracks: const [],
        topGenres: const [
          GenrePreference(genre: 'indie rock', weight: 0.8),
          GenrePreference(genre: 'post-punk', weight: 0.6),
        ],
        lastSyncedAt: null,
      );

      final resultAB = usecase(left: left, right: right);
      final resultBA = usecase(left: right, right: left);

      expect(resultAB.percentage, resultBA.percentage);
      expect(resultAB.artistScore, resultBA.artistScore);
      expect(resultAB.genreScore, resultBA.genreScore);
    });

    test('identical profiles yield high compatibility', () {
      final artists = List.generate(
        50,
        (i) => MusicArtistPreference(id: 'a$i', name: 'A$i', score: 100 - i),
      );
      final genres = const [
        GenrePreference(genre: 'indie rock', weight: 1.0),
        GenrePreference(genre: 'dream pop', weight: 0.7),
        GenrePreference(genre: 'shoegaze', weight: 0.4),
      ];

      final left = MusicProfile(
        id: 'm1',
        userId: 'u1',
        topArtists: artists,
        topTracks: const [],
        topGenres: genres,
        lastSyncedAt: null,
      );

      // Profili identici: artist e genre cosine = 100%, ma niche bonus è < 100
      // perché i generi con weight alto (1.0) producono meno niche bonus.
      // Score finale ≈ 50*1.0 + 35*1.0 + 15*nicheBonus = 85+
      final result = usecase(left: left, right: left);
      expect(result.percentage, greaterThan(80));
      expect(result.artistScore, closeTo(100, 0.1));
      expect(result.genreScore, closeTo(100, 0.1));
    });

    test(
      'shared top artists contribute more than shared low-ranked artists',
      () {
        // Artisti top-5 in comune
        final leftTop = MusicProfile(
          id: 'm1',
          userId: 'u1',
          topArtists: List.generate(
            10,
            (i) =>
                MusicArtistPreference(id: 'a$i', name: 'A$i', score: 100 - i),
          ),
          topTracks: const [],
          topGenres: const [],
          lastSyncedAt: null,
        );

        final rightTop = MusicProfile(
          id: 'm2',
          userId: 'u2',
          topArtists: [
            // Condivide i top-3 (id a0, a1, a2) con score alti
            const MusicArtistPreference(id: 'a0', name: 'A0', score: 100),
            const MusicArtistPreference(id: 'a1', name: 'A1', score: 99),
            const MusicArtistPreference(id: 'a2', name: 'A2', score: 98),
            ...List.generate(
              7,
              (i) =>
                  MusicArtistPreference(id: 'b$i', name: 'B$i', score: 97 - i),
            ),
          ],
          topTracks: const [],
          topGenres: const [],
          lastSyncedAt: null,
        );

        // Artisti in fondo alla lista in comune
        final leftBottom = MusicProfile(
          id: 'm3',
          userId: 'u3',
          topArtists: List.generate(
            10,
            (i) =>
                MusicArtistPreference(id: 'a$i', name: 'A$i', score: 100 - i),
          ),
          topTracks: const [],
          topGenres: const [],
          lastSyncedAt: null,
        );

        final rightBottom = MusicProfile(
          id: 'm4',
          userId: 'u4',
          topArtists: [
            // Condivide gli ultimi 3 (id a7, a8, a9) con score bassi
            ...List.generate(
              7,
              (i) =>
                  MusicArtistPreference(id: 'b$i', name: 'B$i', score: 100 - i),
            ),
            const MusicArtistPreference(id: 'a7', name: 'A7', score: 53),
            const MusicArtistPreference(id: 'a8', name: 'A8', score: 52),
            const MusicArtistPreference(id: 'a9', name: 'A9', score: 51),
          ],
          topTracks: const [],
          topGenres: const [],
          lastSyncedAt: null,
        );

        final topResult = usecase(left: leftTop, right: rightTop);
        final bottomResult = usecase(left: leftBottom, right: rightBottom);

        expect(topResult.artistScore, greaterThan(bottomResult.artistScore));
      },
    );

    test('weighted genres score higher than binary overlap', () {
      final left = MusicProfile(
        id: 'm1',
        userId: 'u1',
        topArtists: const [],
        topTracks: const [],
        topGenres: const [
          GenrePreference(genre: 'house', weight: 1.0),
          GenrePreference(genre: 'electronic', weight: 0.8),
        ],
        lastSyncedAt: null,
      );

      final rightHighWeight = MusicProfile(
        id: 'm2',
        userId: 'u2',
        topArtists: const [],
        topTracks: const [],
        topGenres: const [
          GenrePreference(genre: 'house', weight: 1.0),
          GenrePreference(genre: 'electronic', weight: 0.7),
        ],
        lastSyncedAt: null,
      );

      final rightLowWeight = MusicProfile(
        id: 'm3',
        userId: 'u3',
        topArtists: const [],
        topTracks: const [],
        topGenres: const [
          GenrePreference(genre: 'house', weight: 0.1),
          GenrePreference(genre: 'electronic', weight: 0.1),
        ],
        lastSyncedAt: null,
      );

      final highResult = usecase(left: left, right: rightHighWeight);
      final lowResult = usecase(left: left, right: rightLowWeight);

      // Stessi generi condivisi, ma pesi diversi → score diversi
      expect(highResult.genreScore, greaterThan(lowResult.genreScore));
    });

    test('returns shared artist and genre names', () {
      final left = MusicProfile(
        id: 'm1',
        userId: 'u1',
        topArtists: const [
          MusicArtistPreference(id: 'a1', name: 'Radiohead', score: 100),
          MusicArtistPreference(id: 'a2', name: 'Thom Yorke', score: 90),
          MusicArtistPreference(id: 'a3', name: 'Bjork', score: 80),
        ],
        topTracks: const [],
        topGenres: const [
          GenrePreference(genre: 'art rock', weight: 1.0),
          GenrePreference(genre: 'experimental', weight: 0.6),
        ],
        lastSyncedAt: null,
      );

      final right = MusicProfile(
        id: 'm2',
        userId: 'u2',
        topArtists: const [
          MusicArtistPreference(id: 'a1', name: 'Radiohead', score: 95),
          MusicArtistPreference(id: 'a4', name: 'Portishead', score: 85),
          MusicArtistPreference(id: 'a3', name: 'Bjork', score: 75),
        ],
        topTracks: const [],
        topGenres: const [
          GenrePreference(genre: 'art rock', weight: 0.9),
          GenrePreference(genre: 'trip hop', weight: 0.7),
        ],
        lastSyncedAt: null,
      );

      final result = usecase(left: left, right: right);
      expect(result.sharedArtistNames, contains('Radiohead'));
      expect(result.sharedArtistNames, contains('Bjork'));
      expect(result.sharedArtistNames, isNot(contains('Thom Yorke')));
      expect(result.sharedGenreNames, contains('art rock'));
      expect(result.sharedGenreNames, isNot(contains('experimental')));
    });

    test('niche bonus rewards rare shared genres', () {
      // Due utenti con generi di nicchia in comune
      final leftNiche = MusicProfile(
        id: 'm1',
        userId: 'u1',
        topArtists: const [],
        topTracks: const [],
        topGenres: const [
          GenrePreference(genre: 'pop', weight: 1.0),
          GenrePreference(genre: 'shoegaze', weight: 0.2),
        ],
        lastSyncedAt: null,
      );

      final rightNiche = MusicProfile(
        id: 'm2',
        userId: 'u2',
        topArtists: const [],
        topTracks: const [],
        topGenres: const [
          GenrePreference(genre: 'pop', weight: 1.0),
          GenrePreference(genre: 'shoegaze', weight: 0.3),
        ],
        lastSyncedAt: null,
      );

      final result = usecase(left: leftNiche, right: rightNiche);
      // Il niche bonus deve essere > 0 (shoegaze è di nicchia)
      expect(result.nicheBonus, greaterThan(0));
    });
  });
}
