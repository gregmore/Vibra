import 'package:firebase_core/firebase_core.dart';

import '../../firebase_options.dart';
import '../utils/logger.dart';

/// Bootstrap Firebase opzionale.
/// Se i file nativi non sono ancora configurati, l'app continua a funzionare
/// senza crash e senza servizi push/analytics.
class FirebaseBootstrap {
  FirebaseBootstrap._();

  static bool _initialized = false;
  static bool get isInitialized => _initialized;

  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _initialized = true;
      VibraLogger.info('Firebase inizializzato con successo', tag: 'Firebase');
    } catch (error, stackTrace) {
      VibraLogger.warning(
        'Firebase non configurato o inizializzazione fallita: $error',
        tag: 'Firebase',
      );
      VibraLogger.debug(stackTrace.toString(), tag: 'Firebase');
    }
  }
}
