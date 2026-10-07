import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'fixtures/seeded_test_users.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('E2E seeded profiles & affinity', () {
    tearDown(() async {
      if (SeededE2E.enabled &&
          Supabase.instance.client.auth.currentUser != null) {
        await Supabase.instance.client.auth.signOut(scope: SignOutScope.local);
      }
    });

    testWidgets(
      'profilo molti-match copre score alto, medio, basso e stati sociali',
      (_) async {
        final client = await SeededE2E.signInAs(SeededE2E.manyMatches);
        final userId = client.auth.currentUser!.id;
        final matches = List<Map<String, dynamic>>.from(
          await client
              .from('user_matches')
              .select('compatibility')
              .or('user_id_a.eq.$userId,user_id_b.eq.$userId'),
        );
        final scores = matches
            .map((row) => (row['compatibility'] as num).toDouble())
            .toList(growable: false);

        expect(scores.any((score) => score > 80), isTrue);
        expect(scores.any((score) => score >= 40 && score <= 70), isTrue);
        expect(scores.any((score) => score < 40), isTrue);

        final friendships = List<Map<String, dynamic>>.from(
          await client
              .from('friendships')
              .select('status')
              .or('requester_id.eq.$userId,receiver_id.eq.$userId'),
        );
        final statuses = friendships.map((row) => row['status']).toSet();
        expect(
          statuses,
          containsAll(<String>{'accepted', 'pending', 'rejected'}),
        );
      },
      skip: !SeededE2E.enabled,
    );

    testWidgets(
      'profilo minimale e onboarding interrotto mantengono i fallback attesi',
      (_) async {
        final minimalClient = await SeededE2E.signInAs(SeededE2E.minimal);
        final minimal = await minimalClient
            .from('users')
            .select(
              'username,display_name,avatar_url,spotify_id,last_latitude,'
              'last_longitude,onboarding_completed',
            )
            .single();
        final minimalMusic = await minimalClient
            .from('music_profiles')
            .select('id');

        expect(minimal['username'], 'test_minimal');
        expect(minimal['display_name'], isNull);
        expect(minimal['avatar_url'], isNull);
        expect(minimal['spotify_id'], isNull);
        expect(minimal['last_latitude'], isNull);
        expect(minimal['last_longitude'], isNull);
        expect(minimal['onboarding_completed'], isTrue);
        expect(minimalMusic, isEmpty);

        final halfClient = await SeededE2E.signInAs(SeededE2E.halfOnboarding);
        final half = await halfClient
            .from('users')
            .select(
              'avatar_url,spotify_id,onboarding_completed,onboarding_step',
            )
            .single();
        expect(half['avatar_url'], isNotNull);
        expect(half['spotify_id'], isNull);
        expect(half['onboarding_completed'], isFalse);
        expect(half['onboarding_step'], 'spotify');
      },
      skip: !SeededE2E.enabled,
    );

    testWidgets('profilo completo espone i generi musicali seed', (_) async {
      final client = await SeededE2E.signInAs(SeededE2E.complete);
      final profile = await client
          .from('music_profiles')
          .select('top_genres,last_synced_at')
          .single();
      final genres = List<Map<String, dynamic>>.from(profile['top_genres']);

      expect(genres, hasLength(5));
      expect(
        genres.map((genre) => genre['genre']),
        containsAll(<String>[
          'indie italiano',
          'cantautorato',
          'electropop',
          'alternative dance',
          'pop elettronico',
        ]),
      );
      expect(profile['last_synced_at'], isNotNull);
    }, skip: !SeededE2E.enabled);
  });
}
