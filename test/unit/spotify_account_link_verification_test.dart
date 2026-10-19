import 'package:vibra/core/constants/app_constants.dart';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;
import 'package:vibra/core/errors/exceptions.dart';
import 'package:vibra/data/datasources/spotify_auth_datasource.dart';
import 'package:vibra/data/models/spotify_token_model.dart';
import '../helpers/test_http_overrides.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockFunctionsClient extends Mock implements FunctionsClient {}

void main() {
  // Exercise the retained integration with --dart-define=SPOTIFY_ENABLED=true.
  if (!AppConstants.spotifyEnabled) return;
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    HttpOverrides.global = TestHttpOverrides();
    dotenv.testLoad(
      mergeWith: {
        'SUPABASE_URL': 'https://fake.supabase.co',
        'SUPABASE_ANON_KEY': 'fakeAnonKey',
        'SPOTIFY_CLIENT_ID': 'fakeSpotifyClientId',
        'SPOTIFY_REDIRECT_URI': 'com.vibra.app://callback',
      },
    );
  });

  tearDownAll(() {
    HttpOverrides.global = null;
  });

  group('Spotify Account Single-User Link Verification', () {
    late MockSupabaseClient mockSupabaseClient;
    late MockFunctionsClient mockFunctionsClient;
    late SpotifyAuthDatasource datasource;

    setUp(() {
      mockSupabaseClient = MockSupabaseClient();
      mockFunctionsClient = MockFunctionsClient();
      when(() => mockSupabaseClient.functions).thenReturn(mockFunctionsClient);
      datasource = SpotifyAuthDatasource(supabaseClient: mockSupabaseClient);
    });

    test(
      'exchangeCode succeeds when Spotify account is not linked to any other user',
      () async {
        when(
          () => mockFunctionsClient.invoke(
            'spotify-token-exchange',
            body: any(named: 'body'),
          ),
        ).thenAnswer(
          (_) async => FunctionResponse(
            status: 200,
            data: {
              'access_token': 'mock_access_token',
              'refresh_token': 'mock_refresh_token',
              'expires_in': 3600,
              'scope': 'user-read-private user-top-read',
            },
          ),
        );

        final result = await datasource.exchangeCode(
          code: 'valid_code',
          codeVerifier: 'valid_verifier',
        );

        expect(result, isA<SpotifyTokenModel>());
        expect(result.accessToken, equals('mock_access_token'));
        expect(result.refreshToken, equals('mock_refresh_token'));
      },
    );

    test(
      'exchangeCode throws ServerException with Italian message when Spotify account is already linked to another user',
      () async {
        when(
          () => mockFunctionsClient.invoke(
            'spotify-token-exchange',
            body: any(named: 'body'),
          ),
        ).thenAnswer(
          (_) async => FunctionResponse(
            status: 409,
            data: {
              'error': 'spotify_account_already_linked',
              'message':
                  'Questo account Spotify è già collegato a un altro profilo Vibra.',
            },
          ),
        );

        expect(
          () => datasource.exchangeCode(
            code: 'duplicate_spotify_code',
            codeVerifier: 'valid_verifier',
          ),
          throwsA(
            isA<ServerException>().having(
              (e) => e.message,
              'message',
              contains(
                'Questo account Spotify è già collegato a un altro profilo Vibra.',
              ),
            ),
          ),
        );
      },
    );
  });
}
