import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:vibra/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('E2E Events Flow', () {
    testWidgets('Ricerca eventi, salvataggio e verifica', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // NOTA: Test disabilitato temporaneamente in attesa di Mock API / Local Supabase
      
      /*
      // 1. Apri tab "Esplora"
      await tester.tap(find.byKey(const Key('nav_explore')));
      await tester.pumpAndSettle();

      // 2. Cerca evento per nome
      await tester.enterText(find.byKey(const Key('search_bar')), 'Concerto Rock');
      await tester.pumpAndSettle(const Duration(seconds: 1)); // Attesa debounce

      // Verifica che appaia il risultato
      expect(find.text('Concerto Rock'), findsWidgets);

      // 3. Salva l'evento nei preferiti
      await tester.tap(find.byKey(const Key('save_event_button')).first);
      await tester.pumpAndSettle();

      // 4. Vai nel profilo -> I miei eventi e verifica presenza
      await tester.tap(find.byKey(const Key('nav_profile')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('I miei eventi'));
      await tester.pumpAndSettle();
      
      expect(find.text('Concerto Rock'), findsOneWidget);
      */
    });
  });
}
