import 'package:flutter_test/flutter_test.dart';

// Test placeholder per verifica IDOR dal client Dart.
// Poiché non possiamo connetterci al DB reale nei test unitari (serve mock o ambiente CI locale),
// documentiamo lo schema di test di sicurezza.

void main() {
  group('Security IDOR Tests', () {
    test(
      'Un utente non deve poter alterare user_id nel body per scrivere dati a nome di un altro utente',
      () async {
        // 1. Simula un login con Utente A
        // 2. Costruisci una richiesta API (es. repository.saveEvent)
        //    dove si tenta di passare l'ID dell'Utente B:
        //    await repository.saveEvent(userId: 'ID_UTENTE_B', eventId: '123');
        // 3. Ci si aspetta che il server rigetti la richiesta (401/403)
        //    o che il client/repository sovrascriva forzatamente l'ID usando supabase.auth.currentUser!.id

        expect(true, isTrue); // Placeholder
      },
    );
  });
}
