import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:vibra/app.dart';
import 'package:vibra/presentation/providers/core_providers.dart';
import 'package:vibra/domain/repositories/spotify_auth_repository.dart';
import 'package:vibra/data/datasources/spotify_auth_datasource.dart';
import 'package:vibra/data/models/spotify_token_model.dart';
import '../test/helpers/test_http_overrides.dart';

class MockFlutterAppAuth extends Mock implements FlutterAppAuth {}

class MockSpotifyAuthRepository extends Mock implements SpotifyAuthRepository {}

class MockSpotifyAuthDatasource extends Mock implements SpotifyAuthDatasource {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    HttpOverrides.global = TestHttpOverrides();
    SharedPreferences.setMockInitialValues(const {});
    await Supabase.initialize(
      url: 'https://fake.supabase.co',
      publishableKey: 'fakeAnonKey',
      authOptions: const FlutterAuthClientOptions(
        localStorage: EmptyLocalStorage(),
      ),
    );
  });

  tearDownAll(() {
    HttpOverrides.global = null;
  });

  testWidgets('Test OAuth Flow Mocked', (tester) async {
    final mockAppAuth = MockFlutterAppAuth();
    final mockAuthRepository = MockSpotifyAuthRepository();
    final mockAuthDatasource = MockSpotifyAuthDatasource();

    registerFallbackValue(
      AuthorizationTokenRequest(
        'clientId',
        'redirectUrl',
        serviceConfiguration: const AuthorizationServiceConfiguration(
          authorizationEndpoint: 'auth',
          tokenEndpoint: 'token',
        ),
      ),
    );

    when(() => mockAppAuth.authorizeAndExchangeCode(any())).thenAnswer(
      (_) async => AuthorizationTokenResponse(
        'mock_access_token',
        'mock_refresh_token',
        DateTime.now().add(const Duration(hours: 1)),
        'id_token',
        'token_type',
        null,
        null,
        null,
      ),
    );

    when(() => mockAuthRepository.connectAccount()).thenAnswer(
      (_) async => const SpotifyTokenModel(
        accessToken: 'mock_access_token',
        refreshToken: 'mock_refresh_token',
        expiresIn: 3600,
        scope: '',
      ),
    );

    when(
      () => mockAuthDatasource.syncMusicProfile(),
    ).thenAnswer((_) async => <String, dynamic>{'status': 'success'});

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appAuthProvider.overrideWithValue(mockAppAuth),
          spotifyAuthRepositoryProvider.overrideWithValue(mockAuthRepository),
          spotifyAuthDatasourceProvider.overrideWithValue(mockAuthDatasource),
        ],
        child: const VibraApp(),
      ),
    );

    // Attende splash -> welcome
    await tester.pump(const Duration(milliseconds: 1900));
    await tester.pumpAndSettle();

    // Welcome -> login
    expect(find.textContaining('login'), findsWidgets);
    await tester.tap(find.textContaining('login').first);
    await tester.pumpAndSettle();

    // Login -> SpotifyConnect
    expect(find.text('Continua con Spotify'), findsOneWidget);
    await tester.tap(find.text('Continua con Spotify'));
    await tester.pumpAndSettle();

    // SpotifyConnect -> Home
    expect(find.text('Connetti Spotify'), findsOneWidget);
    await tester.tap(find.text('Collega il mio Spotify'));
    await tester.pumpAndSettle();

    // Now it should be on success state
    expect(find.text('Continua ed Esplora'), findsOneWidget);
    await tester.tap(find.text('Continua ed Esplora'));
    await tester.pumpAndSettle();

    // Verify we reached HomeScreen
    expect(find.text('Per Te'), findsOneWidget);
    expect(find.text('Vicino a Te'), findsOneWidget);
  });
}
