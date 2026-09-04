import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:vibra/domain/entities/app_user.dart';
import 'package:vibra/presentation/providers/spotify_auth_provider.dart';
import 'package:vibra/presentation/providers/app_state_providers.dart';
import 'package:vibra/presentation/providers/auth_provider.dart';
import 'package:vibra/presentation/screens/profile/settings_screen.dart';
import 'package:vibra/presentation/screens/profile/legal_support_screens.dart';
import 'package:vibra/l10n/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  Future<void> disconnectSpotify() async {
    state = const SpotifyAuthStatusState.idle();
  }
}

class FakeProfileController extends ProfileController {
  FakeProfileController(super.ref);

  @override
  AppUser get state => AppUser(
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

Widget buildTestApp(List<Override> overrides, Widget home) {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (_, _) => home),
      GoRoute(
        path: '/privacy-policy',
        builder: (_, _) => const PrivacyPolicyScreen(),
      ),
      GoRoute(
        path: '/terms-of-service',
        builder: (_, _) => const TermsOfServiceScreen(),
      ),
      GoRoute(path: '/support', builder: (_, _) => const SupportScreen()),
      GoRoute(path: '/about', builder: (_, _) => const AboutScreen()),
      GoRoute(
        path: '/login',
        builder: (_, _) => const Scaffold(body: Center(child: Text('Login'))),
      ),
      GoRoute(
        path: '/welcome',
        builder: (_, _) => const Scaffold(body: Center(child: Text('Welcome'))),
      ),
    ],
  );

  return ProviderScope(
    overrides: overrides,
    child: MaterialApp.router(
      routerConfig: router,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('it'),
    ),
  );
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

  testWidgets(
    'Navigazione interna ed interazione bottoni (Filtri, Info, Disconnessione, Scollega)',
    (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        buildTestApp([
          myProfileProvider.overrideWith((ref) => FakeProfileController(ref)),
          spotifyAuthProvider.overrideWith(
            (ref) => MockSpotifyAuthNotifier(ref),
          ),
          generalAuthProvider.overrideWith(
            (ref) => MockGeneralAuthNotifier(ref),
          ),
        ], const SettingsScreen()),
      );
      await tester.pumpAndSettle();

      // 1. Verifica che la SettingsScreen sia visibile
      expect(find.text('Impostazioni'), findsWidgets);

      // 2. Verifica che sia presente il titolo "Account Spotify"
      expect(find.text('Account Spotify'), findsOneWidget);

      // 3. Tap su Privacy Policy e verifica navigazione
      await tester.tap(find.text('Privacy Policy').first);
      await tester.pumpAndSettle();
      expect(find.text('Quali dati raccoglie Vibra'), findsOneWidget);
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      // 4. Tap su Termini di servizio e verifica navigazione
      await tester.tap(find.text('Termini di servizio'));
      await tester.pumpAndSettle();
      expect(find.text('Uso di Vibra'), findsOneWidget);
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      // 5. Tap su Supporto e verifica navigazione
      await tester.tap(find.text('Supporto'));
      await tester.pumpAndSettle();
      expect(find.text('Email supporto'), findsOneWidget);
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      // 6. Tap su Informazioni su Vibra e verifica navigazione
      await tester.tap(find.text('Informazioni su Vibra'));
      await tester.pumpAndSettle();
      expect(find.text('Versione'), findsOneWidget);
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      // 7. Tap su Account Spotify → apre dialog Scollega Spotify
      await tester.tap(find.text('Account Spotify'));
      await tester.pumpAndSettle();
      expect(find.text('Scollega Spotify'), findsOneWidget);
      await tester.tap(find.text('Scollega').last);
      await tester.pumpAndSettle();

      // 8. Tap logout → apre dialog di conferma
      await tester.tap(find.byIcon(Icons.logout_rounded));
      await tester.pumpAndSettle();
      expect(find.text('Sei sicuro di voler uscire?'), findsOneWidget);
      await tester.tap(
        find.descendant(
          of: find.byType(TextButton),
          matching: find.text('Esci'),
        ),
      );
      await tester.pumpAndSettle();
    },
  );
}
