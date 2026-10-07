import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:vibra/core/config/env_config.dart';
import 'package:vibra/core/config/supabase_client.dart';

/// Stable credentials created by `script/seed_test_data.mjs`.
///
/// The password can be overridden in both the seed (`VIBRA_TEST_PASSWORD`) and
/// the test runner (`--dart-define=VIBRA_E2E_PASSWORD=...`).
class SeededTestUser {
  const SeededTestUser({required this.scenario, required this.email});

  final String scenario;
  final String email;

  String get password => SeededE2E.password;
}

abstract final class SeededE2E {
  static const enabled = bool.fromEnvironment(
    'RUN_SEEDED_E2E',
    defaultValue: false,
  );

  static const password = String.fromEnvironment(
    'VIBRA_E2E_PASSWORD',
    defaultValue: 'Vibra-Test!2026',
  );

  /// Required for a hosted Supabase URL. It must match the first hostname
  /// component (the Supabase project ref), preventing accidental prod runs.
  static const expectedProjectRef = String.fromEnvironment(
    'VIBRA_E2E_PROJECT_REF',
  );

  static const complete = SeededTestUser(
    scenario: 'complete',
    email: 'vibra_test_01_complete@example.com',
  );
  static const minimal = SeededTestUser(
    scenario: 'minimal',
    email: 'vibra_test_02_minimal@example.com',
  );
  static const halfOnboarding = SeededTestUser(
    scenario: 'half_onboarding',
    email: 'vibra_test_03_half_onboarding@example.com',
  );
  static const manyMatches = SeededTestUser(
    scenario: 'many_matches',
    email: 'vibra_test_04_many_matches@example.com',
  );
  static const activeChat = SeededTestUser(
    scenario: 'active_chat',
    email: 'vibra_test_05_active_chat@example.com',
  );
  static const blocker = SeededTestUser(
    scenario: 'blocker',
    email: 'vibra_test_06_blocker@example.com',
  );
  static const spotifyExpired = SeededTestUser(
    scenario: 'spotify_expired',
    email: 'vibra_test_07_spotify_expired@example.com',
  );
  static const mixedEvents = SeededTestUser(
    scenario: 'mixed_events',
    email: 'vibra_test_08_mixed_events@example.com',
  );
  static const brandNew = SeededTestUser(
    scenario: 'brand_new',
    email: 'vibra_test_09_brand_new@example.com',
  );
  static const farAway = SeededTestUser(
    scenario: 'far_away',
    email: 'vibra_test_10_far_away@example.com',
  );

  static const all = <SeededTestUser>[
    complete,
    minimal,
    halfOnboarding,
    manyMatches,
    activeChat,
    blocker,
    spotifyExpired,
    mixedEvents,
    brandNew,
    farAway,
  ];

  static Future<SupabaseClient> signInAs(SeededTestUser fixture) async {
    await EnvConfig.load();
    _assertSafeTarget(Uri.parse(EnvConfig.supabaseUrl));
    await SupabaseBootstrap.initialize();

    final client = SupabaseBootstrap.client;
    await client.auth.signOut(scope: SignOutScope.local);
    final response = await client.auth.signInWithPassword(
      email: fixture.email,
      password: fixture.password,
    );
    if (response.user == null) {
      throw StateError('Login fixture fallito: ${fixture.scenario}');
    }
    return client;
  }

  static void _assertSafeTarget(Uri uri) {
    const localHosts = {'localhost', '127.0.0.1', 'host.docker.internal'};
    if (localHosts.contains(uri.host)) return;

    if (expectedProjectRef.isEmpty) {
      throw StateError(
        'E2E remoto bloccato: passa '
        '--dart-define=VIBRA_E2E_PROJECT_REF=<staging-ref>.',
      );
    }
    final actualRef = uri.host.split('.').first;
    if (actualRef != expectedProjectRef) {
      throw StateError(
        'E2E remoto bloccato: project ref $actualRef non è '
        '$expectedProjectRef.',
      );
    }
  }
}
