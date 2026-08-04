import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:integration_test/integration_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:vibra/app.dart';
import 'package:vibra/presentation/providers/spotify_auth_provider.dart';
import 'package:vibra/presentation/providers/core_providers.dart';
import 'package:vibra/data/datasources/supabase_datasource.dart';

class TestHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class MockSpotifyAuthNotifier extends SpotifyAuthNotifier {
  MockSpotifyAuthNotifier(super.ref);

  @override
  Future<void> connectSpotify() async {
    state = const SpotifyAuthStatusState.success();
  }
}

class FakeSupabaseDatasource extends Fake implements SupabaseDatasource {
  @override
  User? get currentUser => User(
    id: 'fake-user-id',
    appMetadata: const {},
    userMetadata: const {},
    aud: 'authenticated',
    createdAt: DateTime.now().toIso8601String(),
  );

  @override
  bool get isAuthenticated => true;

  @override
  Stream<AuthState> get authStateChanges => const Stream.empty();
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  setUpAll(() async {
    HttpOverrides.global = TestHttpOverrides();
    SharedPreferences.setMockInitialValues(const {
      'user_selected_locale': 'it',
    });

    // Inizializza finta istanza Supabase
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

  testWidgets('Bot Esploratore Vibra - Navigazione Completa', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          supabaseDatasourceProvider.overrideWith(
            (ref) => FakeSupabaseDatasource(),
          ),
          spotifyAuthProvider.overrideWith(
            (ref) => MockSpotifyAuthNotifier(ref),
          ),
        ],
        child: const VibraApp(),
      ),
    );

    // Funzione helper per pause visive
    Future<void> pausa([int secondi = 2]) async {
      await tester.pump(Duration(seconds: secondi));
      await tester.pumpAndSettle();
    }

    // 1. Splash Screen e Welcome
    debugPrint('BOT: Avvio Splash Screen e Welcome...');
    await pausa(2);

    final loginButton = find.textContaining(
      RegExp(r'login|inizia', caseSensitive: false),
    );
    if (loginButton.evaluate().isNotEmpty) {
      await tester.tap(loginButton.first);
      await pausa(1);
    }

    // 2. Continua con Spotify
    debugPrint('BOT: Superando Autenticazione...');
    final spotifyBtn = find.text('Continua con Spotify');
    if (spotifyBtn.evaluate().isNotEmpty) {
      await tester.tap(spotifyBtn);
      await pausa(1);
    }

    // 3. Collega Spotify
    debugPrint('BOT: Collegamento account mockato...');
    final collegaBtn = find.text('Collega il mio Spotify');
    if (collegaBtn.evaluate().isNotEmpty) {
      await tester.tap(collegaBtn);
      await pausa(2); // Aspetta che finisca il "collegamento"
    }

    // 4. Continua ed Esplora
    final esploraBtn = find.text('Continua ed Esplora');
    if (esploraBtn.evaluate().isNotEmpty) {
      await tester.tap(esploraBtn);
      await pausa(2);
    }

    // 5. Home: Scrolliamo un po'
    debugPrint('BOT: Esplorazione Home...');
    final homeScrolls = find.byType(SingleChildScrollView);
    if (homeScrolls.evaluate().isNotEmpty) {
      await tester.drag(homeScrolls.first, const Offset(0, -300));
      await pausa(1);
      await tester.drag(homeScrolls.first, const Offset(0, 300));
      await pausa(1);
    }

    // 6. Vai a Esplora / Eventi
    debugPrint('BOT: Navigazione verso Eventi/Esplora...');
    final navExplore = find.byIcon(Icons.explore_outlined);
    if (navExplore.evaluate().isNotEmpty) {
      await tester.tap(navExplore.first);
      await pausa(2);
    }

    // 7. Vai ai Preferiti (Vibra)
    debugPrint('BOT: Navigazione verso Preferiti...');
    final navFav = find.byIcon(Icons.favorite_border_rounded);
    if (navFav.evaluate().isNotEmpty) {
      await tester.tap(navFav.first);
      await pausa(2);
    }

    // 8. Vai alla Chat
    debugPrint('BOT: Navigazione verso Chat...');
    final navChat = find.byIcon(Icons.chat_bubble_outline_rounded);
    if (navChat.evaluate().isNotEmpty) {
      await tester.tap(navChat.first);
      await pausa(2);
    }

    // 9. Vai al Profilo
    debugPrint('BOT: Navigazione verso Profilo...');
    final navProfile = find.byIcon(Icons.person_outline_rounded);
    if (navProfile.evaluate().isNotEmpty) {
      await tester.tap(navProfile.first);
      await pausa(2);
    }

    // 10. Torna alla Home
    debugPrint('BOT: Torno alla Home...');
    final navHome = find.byIcon(Icons.home_outlined);
    if (navHome.evaluate().isNotEmpty) {
      await tester.tap(navHome.first);
      await pausa(2);
    }

    // Finito
    debugPrint('BOT: Dimostrazione completata!');
    await pausa(2);
  });
}
