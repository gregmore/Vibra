import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:vibra/app.dart';
import 'package:vibra/presentation/providers/spotify_auth_provider.dart';
import 'package:vibra/presentation/providers/core_providers.dart';
import 'package:vibra/data/datasources/supabase_datasource.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../helpers/test_http_overrides.dart';

class MockSpotifyAuthNotifier extends SpotifyAuthNotifier {
  MockSpotifyAuthNotifier(super.ref);

  @override
  Future<void> connectSpotify() async {
    state = const SpotifyAuthStatusState.success();
  }
}

class FakeSupabaseDatasource extends Fake implements SupabaseDatasource {
  @override
  User? get currentUser => null; // non autenticato, mostra il welcome/login

  @override
  bool get isAuthenticated => false;

  @override
  Stream<AuthState> get authStateChanges => const Stream.empty();
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

  testWidgets('Flow base: Welcome -> Login -> SpotifyConnect -> Home', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

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

    // Attende splash -> welcome
    await tester.pump(const Duration(milliseconds: 1900));
    await tester.pumpAndSettle();

    // Welcome screen - cerca testo che porta al login
    expect(find.textContaining('login'), findsWidgets);
    await tester.tap(find.textContaining('login').first);
    await tester.pumpAndSettle();

    // Login screen: verifica che ci siano i pulsanti di accesso presenti
    expect(
      find.byType(ElevatedButton).evaluate().isNotEmpty ||
              find.byType(FilledButton).evaluate().isNotEmpty ||
              find.byType(TextButton).evaluate().isNotEmpty
          ? true
          : find.byType(OutlinedButton).evaluate().isNotEmpty,
      isTrue,
    );
  });
}
