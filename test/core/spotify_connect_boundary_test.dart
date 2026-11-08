import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vibra/core/services/spotify_token_storage.dart';
import 'package:vibra/data/datasources/spotify_auth_datasource.dart';
import 'package:vibra/data/models/spotify_token_model.dart';
import 'package:vibra/data/repositories/spotify_auth_repository_impl.dart';

class Source extends Mock implements SpotifyAuthDatasource {}

class Client extends Mock implements SupabaseClient {}

class Auth extends Mock implements GoTrueClient {}

class Tokens extends Mock implements SpotifyTokenStorage {}

User _user(String id) => User(
  id: id,
  appMetadata: const {},
  userMetadata: const {},
  aud: 'authenticated',
  createdAt: '2026-01-01',
);

void main() {
  late Source source;
  late Auth auth;
  late Tokens tokens;
  late User current;

  setUp(() {
    source = Source();
    final client = Client();
    auth = Auth();
    tokens = Tokens();
    current = _user('alice');
    when(() => source.supabaseClient).thenReturn(client);
    when(() => client.auth).thenReturn(auth);
    when(() => auth.currentSession).thenReturn(
      Session(accessToken: 'vibra-alice', tokenType: 'bearer', user: current),
    );
    when(() => auth.currentUser).thenAnswer((_) => current);
    when(() => source.generateCodeVerifier()).thenReturn('verifier');
    when(
      () => source.generateCodeChallenge('verifier'),
    ).thenReturn('challenge');
    when(() => source.generateState()).thenReturn('state');
    when(
      () => source.authenticate(codeChallenge: 'challenge', state: 'state'),
    ).thenAnswer((_) async => 'code');
    when(() => tokens.clear()).thenAnswer((_) async {});
  });

  test(
    'connect uses PKCE, never stores Spotify tokens and wipes legacy ones',
    () async {
      when(
        () => source.exchangeCode(
          code: 'code',
          codeVerifier: 'verifier',
          vibraAccessToken: 'vibra-alice',
        ),
      ).thenAnswer(
        (_) async =>
            const SpotifyTokenModel(expiresIn: 3600, scope: 'user-top-read'),
      );
      var authorized = false;
      final session = await SpotifyAuthRepositoryImpl(
        datasource: source,
        tokenStorage: tokens,
      ).connectAccount(onAuthorized: () => authorized = true);

      expect(authorized, isTrue);
      expect(session.scopes, ['user-top-read']);
      verify(() => tokens.clear()).called(1);
      verifyNever(() => tokens.saveAccessToken(any()));
      verifyNever(() => tokens.saveRefreshToken(any()));
    },
  );

  test(
    'an account switch during consent stops before the code exchange',
    () async {
      when(
        () => source.authenticate(codeChallenge: 'challenge', state: 'state'),
      ).thenAnswer((_) async {
        current = _user('bob');
        return 'code';
      });
      await expectLater(
        SpotifyAuthRepositoryImpl(
          datasource: source,
          tokenStorage: tokens,
        ).connectAccount(),
        throwsStateError,
      );
      verifyNever(
        () => source.exchangeCode(
          code: any(named: 'code'),
          codeVerifier: any(named: 'codeVerifier'),
          vibraAccessToken: any(named: 'vibraAccessToken'),
        ),
      );
    },
  );
}
