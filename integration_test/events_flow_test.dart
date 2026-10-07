import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'fixtures/seeded_test_users.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('E2E seeded events', () {
    tearDown(() async {
      if (SeededE2E.enabled &&
          Supabase.instance.client.auth.currentUser != null) {
        await Supabase.instance.client.auth.signOut(scope: SignOutScope.local);
      }
    });

    testWidgets(
      'fixture eventi contiene arrivo, passato, sold-out, cancellato e rinviato',
      (_) async {
        final client = await SeededE2E.signInAs(SeededE2E.mixedEvents);
        final attendeeRows = List<Map<String, dynamic>>.from(
          await client
              .from('event_attendees')
              .select('event_id,status')
              .neq('status', 'not_going'),
        );
        expect(attendeeRows, hasLength(5));

        final eventIds = attendeeRows
            .map((row) => row['event_id'].toString())
            .toList(growable: false);
        final events = List<Map<String, dynamic>>.from(
          await client
              .from('events')
              .select('id,name,event_date,status,is_test_data')
              .inFilter('id', eventIds),
        );

        final now = DateTime.now();
        expect(
          events.any(
            (event) =>
                DateTime.parse(event['event_date'].toString()).isBefore(now),
          ),
          isTrue,
        );
        expect(
          events.any(
            (event) =>
                DateTime.parse(event['event_date'].toString()).isAfter(now),
          ),
          isTrue,
        );
        expect(events.map((event) => event['status']), contains('offsale'));
        expect(events.map((event) => event['status']), contains('canceled'));
        expect(events.map((event) => event['status']), contains('postponed'));
        expect(events.every((event) => event['is_test_data'] == true), isTrue);
      },
      skip: !SeededE2E.enabled,
    );

    testWidgets(
      'profilo lontano salva solo evento della città lontana',
      (_) async {
        final client = await SeededE2E.signInAs(SeededE2E.farAway);
        final rows = List<Map<String, dynamic>>.from(
          await client
              .from('event_attendees')
              .select('events(name,city),status'),
        );
        expect(rows, hasLength(1));
        final event = rows.single['events'] as Map<String, dynamic>;
        expect(event['name'], 'TEST Far City Sessions');
      },
      skip: !SeededE2E.enabled,
    );
  });
}
