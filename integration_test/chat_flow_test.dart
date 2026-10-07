import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'fixtures/seeded_test_users.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('E2E seeded chat & moderation', () {
    tearDown(() async {
      if (SeededE2E.enabled &&
          Supabase.instance.client.auth.currentUser != null) {
        await Supabase.instance.client.auth.signOut(scope: SignOutScope.local);
      }
    });

    testWidgets(
      'chat attiva espone non letti, richiesta messaggio e condivisione evento',
      (_) async {
        final client = await SeededE2E.signInAs(SeededE2E.activeChat);
        final conversations = List<Map<String, dynamic>>.from(
          await client.rpc('get_user_conversations'),
        );
        final unread = conversations.fold<int>(
          0,
          (sum, row) => sum + ((row['unread_count'] as num?)?.toInt() ?? 0),
        );
        expect(conversations.length, greaterThanOrEqualTo(3));
        expect(unread, greaterThanOrEqualTo(4));
        expect(
          conversations.any((row) => row['is_message_request'] == true),
          isTrue,
        );

        final sharedEvents = List<Map<String, dynamic>>.from(
          await client
              .from('messages')
              .select('content,message_type,metadata')
              .eq('message_type', 'event_share'),
        );
        expect(sharedEvents, hasLength(1));
        expect(
          (sharedEvents.single['metadata'] as Map<String, dynamic>)['event_id'],
          isNotEmpty,
        );
      },
      skip: !SeededE2E.enabled,
    );

    testWidgets(
      'blocco reciproco nasconde la chat e impedisce nuovi messaggi',
      (_) async {
        final client = await SeededE2E.signInAs(SeededE2E.blocker);
        final blockedProfile = await client
            .from('users_public')
            .select('id')
            .eq('username', 'test_spotify_expired')
            .single();
        final blockedId = blockedProfile['id'].toString();

        final visibleMessages = await client
            .from('messages')
            .select('id')
            .or(
              'and(sender_id.eq.$blockedId,receiver_id.eq.${client.auth.currentUser!.id}),'
              'and(sender_id.eq.${client.auth.currentUser!.id},receiver_id.eq.$blockedId)',
            );
        expect(visibleMessages, isEmpty);

        await expectLater(
          client.from('messages').insert({
            'sender_id': client.auth.currentUser!.id,
            'receiver_id': blockedId,
            'content': 'Questo messaggio deve essere bloccato dal backend.',
          }),
          throwsA(isA<PostgrestException>()),
        );
      },
      skip: !SeededE2E.enabled,
    );
  });
}
