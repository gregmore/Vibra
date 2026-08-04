import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:vibra/app.dart';
import 'package:vibra/domain/entities/app_user.dart';
import 'package:vibra/presentation/providers/spotify_auth_provider.dart';
import 'package:vibra/presentation/providers/core_providers.dart';
import 'package:vibra/data/datasources/supabase_datasource.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibra/domain/usecases/profile_usecases.dart';
import 'package:vibra/domain/usecases/usecase.dart';
import 'package:vibra/presentation/providers/usecase_providers.dart';
import 'package:vibra/presentation/providers/auth_provider.dart';
import '../helpers/test_http_overrides.dart';

class MockGeneralAuthNotifier extends GeneralAuthNotifier {
  MockGeneralAuthNotifier(super.ref);

  @override
  Future<void> signOut({SignOutScope scope = SignOutScope.local}) async {
    state = const GeneralAuthState.idle();
  }
}

class MockSpotifyAuthNotifier extends SpotifyAuthNotifier {
  MockSpotifyAuthNotifier(super.ref);

  @override
  Future<void> connectSpotify() async {
    state = const SpotifyAuthStatusState.success();
  }

  @override
  Future<void> disconnectSpotify() async {
    state = const SpotifyAuthStatusState.idle();
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

class FakeGetMyProfileUseCase extends Fake implements GetMyProfileUseCase {
  @override
  Future<AppUser> call(NoParams params) async {
    return AppUser(
      id: 'fake-user-id',
      email: 'gregorio@vibra.it',
      username: 'gregorio',
      displayName: 'Gregorio',
      spotifyId: 'fake-spotify-id',
      bio: 'Amo la musica live!',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    HttpOverrides.global = TestHttpOverrides();
    SharedPreferences.setMockInitialValues(const {
      'user_selected_locale': 'it',
    });
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

  testWidgets('Navigazione interna ed interazione bottoni (Filtri, Info, Disconnessione, Scollega)', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          supabaseDatasourceProvider.overrideWith((ref) => FakeSupabaseDatasource()),
          spotifyAuthProvider.overrideWith((ref) => MockSpotifyAuthNotifier(ref)),
          getMyProfileUseCaseProvider.overrideWith((ref) => FakeGetMyProfileUseCase()),
          generalAuthProvider.overrideWith((ref) => MockGeneralAuthNotifier(ref)),
        ],
        child: const VibraApp(),
      ),
    );

    // Attende splash -> welcome
    await tester.pump(const Duration(milliseconds: 1900));
    await tester.pumpAndSettle();

    // Tap su "login"
    await tester.tap(find.textContaining('login').first);
    await tester.pumpAndSettle();

    // Tap su "Continua con Spotify"
    await tester.tap(find.text('Continua con Spotify'));
    await tester.pumpAndSettle();

    // Collega Spotify
    await tester.tap(find.text('Collega il mio Spotify'));
    await tester.pumpAndSettle();

    // Vai alla Home
    await tester.tap(find.text('Continua ed Esplora'));
    await tester.pumpAndSettle();

    // 1. Verifica Home
    expect(find.text('Per Te'), findsOneWidget);

    // 2. Naviga alla tab Eventi (Explore)
    await tester.tap(find.text('Eventi').first);
    await tester.pumpAndSettle();
    expect(find.text('Mappa interattiva'), findsOneWidget);

    // 3. Naviga alla tab Vibra
    await tester.tap(find.text('Vibra'));
    await tester.pumpAndSettle();

    // 4. Naviga alla tab Chat
    await tester.tap(find.text('Chat'));
    await tester.pumpAndSettle();

    // 5. Naviga alla tab Profilo
    await tester.tap(find.text('Profilo'));
    await tester.pumpAndSettle();
    expect(find.text('Amo la musica live!'), findsOneWidget);

    // 6. Apri Impostazioni
    await tester.tap(find.text('Impostazioni').first);
    await tester.pumpAndSettle();
    
    expect(find.text('Account Spotify'), findsOneWidget);

    // 7. Apri e chiudi Privacy Policy
    await tester.tap(find.text('Privacy Policy'));
    await tester.pumpAndSettle();
    expect(find.text('Quali dati raccoglie Vibra'), findsOneWidget);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    // 8. Apri e chiudi Termini di servizio
    await tester.tap(find.text('Termini di servizio'));
    await tester.pumpAndSettle();
    expect(find.text('Uso di Vibra'), findsOneWidget);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    // 9. Apri e chiudi Supporto
    await tester.tap(find.text('Supporto'));
    await tester.pumpAndSettle();
    expect(find.text('Email supporto'), findsOneWidget);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    // 10. Apri e chiudi Informazioni su Vibra
    await tester.tap(find.text('Informazioni su Vibra'));
    await tester.pumpAndSettle();
    expect(find.text('Versione'), findsOneWidget);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    // 11. Clicca su Scollega Spotify, conferma dialog
    await tester.tap(find.text('Account Spotify'));
    await tester.pumpAndSettle();
    expect(find.text('Scollega Spotify'), findsOneWidget); // Titolo del dialog
    await tester.tap(find.text('Scollega').last);
    await tester.pumpAndSettle();

    // 12. Clicca su Logout, conferma dialog
    await tester.tap(find.byIcon(Icons.logout_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Sei sicuro di voler uscire?'), findsOneWidget);
    await tester.tap(find.descendant(
      of: find.byType(TextButton),
      matching: find.text('Esci'),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Vai al login'), findsWidgets);
  });
}
