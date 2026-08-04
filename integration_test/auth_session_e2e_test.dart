import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:vibra/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('E2E Auth & Session Flow', () {
    testWidgets('Login -> Salva Evento -> Logout -> Nuovo Login (Nessun residuo)', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // NOTA: Questo è uno scheletro di test E2E.
      // A causa dell'autenticazione tramite provider esterni (Spotify/Supabase),
      // i test E2E reali richiedono il mocking del client Supabase o l'uso di
      // account di test pre-generati con password.

      /*
      // 1. Login Utente A
      await tester.enterText(find.byKey(const Key('email_field')), 'utente_a@test.com');
      await tester.enterText(find.byKey(const Key('password_field')), 'password123');
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle();

      // Verifica Home
      expect(find.text('Home'), findsOneWidget);

      // 2. Salva un evento
      await tester.tap(find.byKey(const Key('save_event_button_0')));
      await tester.pumpAndSettle();

      // 3. Verifica evento salvato nei "Miei Eventi"
      await tester.tap(find.byKey(const Key('nav_profile')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('I miei eventi'));
      await tester.pumpAndSettle();
      expect(find.byType(ListTile), findsWidgets); // Almeno un evento salvato

      // 4. Logout Utente A
      await tester.tap(find.byKey(const Key('settings_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Esci'));
      await tester.pumpAndSettle();

      // Verifica Ritorno a Login
      expect(find.byKey(const Key('login_button')), findsOneWidget);

      // 5. Login Utente B
      await tester.enterText(find.byKey(const Key('email_field')), 'utente_b@test.com');
      await tester.enterText(find.byKey(const Key('password_field')), 'password123');
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle();

      // 6. Verifica "Miei Eventi" Utente B è vuoto (nessun residuo da A)
      await tester.tap(find.byKey(const Key('nav_profile')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('I miei eventi'));
      await tester.pumpAndSettle();
      
      // Assicura che la lista eventi sia vuota o mostri lo stato "nessun evento"
      expect(find.text('Nessun evento salvato'), findsOneWidget);
      */
    });
  });
}
