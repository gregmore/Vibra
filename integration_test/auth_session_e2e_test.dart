import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vibra/core/router/app_router.dart';
import 'package:vibra/main.dart' as app;

import 'fixtures/seeded_test_users.dart';

Future<void> _pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 20),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (finder.evaluate().isEmpty && DateTime.now().isBefore(deadline)) {
    await tester.pump(const Duration(milliseconds: 250));
  }
  expect(finder, findsWidgets);
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('E2E seeded auth & isolation', () {
    tearDown(() async {
      if (SeededE2E.enabled &&
          Supabase.instance.client.auth.currentUser != null) {
        await Supabase.instance.client.auth.signOut(scope: SignOutScope.local);
      }
    });

    testWidgets(
      'profilo completo effettua login e raggiunge Home sincronizzata',
      (tester) async {
        await SeededE2E.signInAs(SeededE2E.complete);
        await app.bootstrapAndRun(
          installGlobalErrorHandler: false,
          initializeNativeServices: false,
        );
        await tester.pump();

        // AppRouter intentionally disables redirects under a test binding, so
        // navigate explicitly after validating the authenticated fixture.
        final context = AppRouter.rootNavigatorKey.currentContext!;
        if (!context.mounted) {
          fail('Navigator non montato dopo il bootstrap dell\'app');
        }
        GoRouter.of(context).go('/home');

        await _pumpUntilFound(
          tester,
          find.textContaining('Spotify sincronizzato'),
        );
        expect(find.textContaining('TEST Giulia Completa'), findsWidgets);

        if (!context.mounted) {
          fail('Navigator smontato durante il caricamento');
        }
        GoRouter.of(context).go('/music-stats');
        await _pumpUntilFound(tester, find.text('indie italiano'));
        expect(find.text('pop elettronico'), findsOneWidget);
      },
      skip: !SeededE2E.enabled,
    );

    testWidgets(
      'utente auth-only non eredita dati privati da una sessione precedente',
      (tester) async {
        final completeClient = await SeededE2E.signInAs(SeededE2E.complete);
        final completeSaved = await completeClient
            .from('event_attendees')
            .select('id');
        expect(completeSaved, isNotEmpty);

        final freshClient = await SeededE2E.signInAs(SeededE2E.brandNew);
        final freshProfile = await freshClient.from('users').select('id');
        final freshSaved = await freshClient
            .from('event_attendees')
            .select('id');
        final freshMessages = await freshClient.from('messages').select('id');
        final freshMatches = await freshClient
            .from('user_matches')
            .select('id');
        final freshNotifications = await freshClient
            .from('notifications')
            .select('id');

        // User 09 is deliberately auth-only until Vibra bootstraps the profile.
        expect(freshProfile, isEmpty);
        expect(freshSaved, isEmpty);
        expect(freshMessages, isEmpty);
        expect(freshMatches, isEmpty);
        expect(freshNotifications, isEmpty);
      },
      skip: !SeededE2E.enabled,
    );
  });
}
