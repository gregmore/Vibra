import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Mock Dependencies
class MockSpotifyAuthService extends Mock implements SpotifyAuthService {}

class MockMusicProfileRepository extends Mock
    implements MusicProfileRepository {}

class MockGoRouter extends Mock {}

// Classi fittizie per rappresentare i DataLayer dell'app Vibra
class SpotifyAuthService {
  Future<String> handleOAuthCallback(Uri uri) async {
    throw UnimplementedError();
  }

  Future<Map<String, dynamic>> fetchSpotifyData(String token) async {
    throw UnimplementedError();
  }
}

class MusicProfileRepository {
  Future<void> saveProfile(List<String> artists, List<String> genres) async {
    throw UnimplementedError();
  }
}

// Simuliamo l'use case di sincronizzazione
class SyncSpotifyProfileUseCase {
  final SpotifyAuthService authService;
  final MusicProfileRepository repository;

  SyncSpotifyProfileUseCase(this.authService, this.repository);

  Future<void> execute(Uri callbackUri) async {
    try {
      final token = await authService.handleOAuthCallback(callbackUri);
      final data = await authService.fetchSpotifyData(token);

      // Fallback sicuro in caso di dati mancanti/vuoti
      final artists = (data['artists'] as List?)?.cast<String>() ?? [];
      final genres = (data['genres'] as List?)?.cast<String>() ?? [];

      await repository.saveProfile(artists, genres);
    } catch (e) {
      // Gestione eccezione per fallback grazioso senza crash
      await repository.saveProfile([], []);
    }
  }
}

void main() {
  late MockSpotifyAuthService mockAuthService;
  late MockMusicProfileRepository mockRepository;
  late SyncSpotifyProfileUseCase useCase;

  setUp(() {
    mockAuthService = MockSpotifyAuthService();
    mockRepository = MockMusicProfileRepository();
    useCase = SyncSpotifyProfileUseCase(mockAuthService, mockRepository);

    // Fallback registration per Mocktail
    registerFallbackValue(Uri());
  });

  group('Spotify OAuth & Sync Integration', () {
    test(
      'Should fallback gracefully to empty lists when Spotify profile is brand new (0 artists, 0 genres)',
      () async {
        // ARRANGE
        final mockUri = Uri.parse('vibra://oauth/callback?code=fake_auth_code');
        final fakeToken = 'mock_spotify_token';

        when(
          () => mockAuthService.handleOAuthCallback(mockUri),
        ).thenAnswer((_) async => fakeToken);

        // Simuliamo il payload di un utente appena iscritto a Spotify (array vuoti o nulli)
        when(() => mockAuthService.fetchSpotifyData(fakeToken)).thenAnswer(
          (_) async => {
            'artists': [],
            'genres': null, // Simuliamo un possibile dato mancante
          },
        );

        when(
          () => mockRepository.saveProfile(any(), any()),
        ).thenAnswer((_) async => {});

        // ACT
        await useCase.execute(mockUri);

        // ASSERT
        // Verifichiamo che il token sia stato estratto correttamente
        verify(() => mockAuthService.handleOAuthCallback(mockUri)).called(1);
        verify(() => mockAuthService.fetchSpotifyData(fakeToken)).called(1);

        // Verifichiamo che il salvataggio sia avvenuto con successo passando liste vuote (fallback)
        verify(() => mockRepository.saveProfile([], [])).called(1);
      },
    );

    test(
      'Should catch exceptions and save empty profile without crashing',
      () async {
        // ARRANGE
        final mockUri = Uri.parse('vibra://oauth/callback?code=invalid_code');

        when(
          () => mockAuthService.handleOAuthCallback(mockUri),
        ).thenThrow(Exception('Network Error or Expired Code'));

        when(
          () => mockRepository.saveProfile(any(), any()),
        ).thenAnswer((_) async => {});

        // ACT
        // L'esecuzione non deve sollevare eccezioni
        await useCase.execute(mockUri);

        // ASSERT
        // Deve aver gestito l'errore salvando liste vuote senza crashare l'app
        verify(() => mockRepository.saveProfile([], [])).called(1);
      },
    );
  });
}
