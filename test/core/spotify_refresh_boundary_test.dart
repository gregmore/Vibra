import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vibra/data/datasources/spotify_auth_datasource.dart';
import 'package:vibra/data/models/spotify_token_model.dart';
import 'package:vibra/data/repositories/spotify_auth_repository_impl.dart';
import 'package:vibra/core/services/spotify_token_storage.dart';

class Source extends Mock implements SpotifyAuthDatasource {}

class Client extends Mock implements SupabaseClient {}

class Auth extends Mock implements GoTrueClient {}

class Tokens extends Mock implements SpotifyTokenStorage {}

void main() {
  for (final changed in [false, true]) {
    test(
      'refresh with account change=$changed keeps identity boundary',
      () async {
        final source = Source();
        final client = Client();
        final auth = Auth();
        final tokens = Tokens();
        final a = User(
          id: 'alice',
          appMetadata: {},
          userMetadata: {},
          aud: 'authenticated',
          createdAt: '2026-01-01',
        );
        final b = User(
          id: 'bob',
          appMetadata: {},
          userMetadata: {},
          aud: 'authenticated',
          createdAt: '2026-01-01',
        );
        var current = a;
        when(() => source.supabaseClient).thenReturn(client);
        when(() => client.auth).thenReturn(auth);
        when(() => auth.currentSession).thenReturn(
          Session(accessToken: 'vibra-alice', tokenType: 'bearer', user: a),
        );
        when(() => auth.currentUser).thenAnswer((_) => current);
        when(
          () => tokens.readRefreshToken(),
        ).thenAnswer((_) async => 'spotify-alice-refresh');
        when(() => tokens.saveAccessToken(any())).thenAnswer((_) async {});
        when(() => tokens.saveRefreshToken(any())).thenAnswer((_) async {});
        when(
          () => source.refreshSession(
            refreshToken: 'spotify-alice-refresh',
            vibraAccessToken: 'vibra-alice',
          ),
        ).thenAnswer((_) async {
          if (changed) current = b;
          return const SpotifyTokenModel(
            accessToken: 'new-alice',
            refreshToken: 'new-refresh',
            expiresIn: 3600,
          );
        });
        final repository = SpotifyAuthRepositoryImpl(
          datasource: source,
          tokenStorage: tokens,
        );
        if (changed) {
          await expectLater(repository.refreshSession(), throwsStateError);
          verifyNever(() => tokens.saveAccessToken(any()));
          verifyNever(() => tokens.saveRefreshToken(any()));
        } else {
          expect((await repository.refreshSession()).accessToken, 'new-alice');
          verify(() => tokens.saveAccessToken('new-alice')).called(1);
        }
        verify(
          () => source.refreshSession(
            refreshToken: 'spotify-alice-refresh',
            vibraAccessToken: 'vibra-alice',
          ),
        ).called(1);
      },
    );
  }
}
