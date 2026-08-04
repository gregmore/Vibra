import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:vibra/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('E2E Chat Flow', () {
    testWidgets('Apertura chat, invio messaggio, offline', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // NOTA: Questo test richiede un setup complesso con due utenti loggati,
      // oppure un mock della ricezione messaggi da Supabase Realtime.

      /*
      // 1. Vai alla sezione Amici
      await tester.tap(find.byKey(const Key('nav_social')));
      await tester.pumpAndSettle();

      // 2. Apri la chat con il primo amico
      await tester.tap(find.byKey(const Key('open_chat_button_0')));
      await tester.pumpAndSettle();

      // 3. Invia messaggio
      await tester.enterText(find.byType(TextField), 'Ciao, andiamo al concerto?');
      await tester.tap(find.byIcon(Icons.send_rounded));
      await tester.pumpAndSettle();

      // Verifica che il messaggio compaia nella UI
      expect(find.text('Ciao, andiamo al concerto?'), findsOneWidget);

      // (Opzionale) 4. Simula offline disabilitando la connessione
      // Questo richiede interazione con OS (es. Patrol) o Mock del network status.
      */
    });
  });
}
