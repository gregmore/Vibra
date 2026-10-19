import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vibra/core/constants/app_constants.dart';
import 'package:vibra/core/errors/exceptions.dart';
import 'package:vibra/data/datasources/spotify_auth_datasource.dart';
import 'package:vibra/presentation/providers/app_state_providers.dart';
import 'package:vibra/presentation/providers/core_providers.dart';
import 'package:vibra/presentation/providers/spotify_auth_provider.dart';
import 'package:vibra/presentation/providers/usecase_providers.dart';

class _Client extends Mock implements SupabaseClient {}

void main() {
  if (AppConstants.spotifyEnabled) return;

  final operations = <String, Future<Object?> Function(SpotifyAuthDatasource)>{
    'browser authorization': (source) =>
        source.authenticate(codeChallenge: 'unused', state: 'unused'),
    'token exchange': (source) =>
        source.exchangeCode(code: 'unused', codeVerifier: 'unused'),
    'token refresh': (source) => source.refreshSession(refreshToken: 'unused'),
    'profile synchronization': (source) => source.syncMusicProfile(),
  };
  for (final operation in operations.entries) {
    test(
      'Disabled Spotify rejects ${operation.key} before external work',
      () async {
        final client = _Client();
        await expectLater(
          operation.value(SpotifyAuthDatasource(supabaseClient: client)),
          throwsA(
            isA<ServerException>().having(
              (error) => error.message,
              'message',
              'spotify_temporarily_unavailable',
            ),
          ),
        );
        verifyZeroInteractions(client);
      },
    );
  }

  test(
    'Disabled controllers never read musical data or open match subscriptions',
    () async {
      final container = ProviderContainer(
        overrides: [
          supabaseDatasourceProvider.overrideWith(
            (ref) => throw StateError('Unexpected backend read'),
          ),
          getMyMusicProfileUseCaseProvider.overrideWith(
            (ref) => throw StateError('Unexpected music lookup'),
          ),
        ],
      );
      addTearDown(container.dispose);
      expect(container.read(myMusicProfileProvider).topArtists, isEmpty);
      expect(container.read(matchedUsersProvider), isEmpty);
      await container.read(myMusicProfileProvider.notifier).refresh();
      await container.read(matchedUsersProvider.notifier).refresh();
      await Future<void>.delayed(Duration.zero);
      expect(container.read(myMusicProfileProvider).topArtists, isEmpty);
      expect(container.read(matchedUsersProvider), isEmpty);
    },
  );

  test(
    'Connect and sync preserve the disabled state without loading repositories',
    () async {
      final container = ProviderContainer(
        overrides: [
          spotifyAuthRepositoryProvider.overrideWith(
            (ref) => throw StateError('Unexpected connection'),
          ),
          spotifyAuthDatasourceProvider.overrideWith(
            (ref) => throw StateError('Unexpected synchronization'),
          ),
        ],
      );
      addTearDown(container.dispose);
      await container.read(spotifyAuthProvider.notifier).connectSpotify();
      expect(
        container.read(spotifyAuthProvider).errorMessage,
        'spotify_temporarily_unavailable',
      );
      await container.read(spotifyAuthProvider.notifier).syncSpotify();
      expect(
        container.read(spotifyAuthProvider).errorMessage,
        'spotify_temporarily_unavailable',
      );
    },
  );
}
