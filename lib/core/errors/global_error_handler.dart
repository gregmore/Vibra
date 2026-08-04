import 'package:flutter/foundation.dart';
import '../utils/logger.dart';

/// Centralizza la gestione degli errori per l'applicazione, prevenendo crash fatali
/// "schermo grigio" e inoltrando la telemetria in modo uniforme.
class GlobalErrorHandler {
  static void initialize() {
    // Gestione degli errori Flutter (es: errori di rendering, eccezioni del framework)
    FlutterError.onError = (FlutterErrorDetails details) {
      VibraLogger.error(
        'FlutterError catturato dal GlobalErrorHandler',
        error: details.exception,
        stackTrace: details.stack,
        tag: 'GlobalErrorHandler',
      );

      // In produzione: FirebaseCrashlytics.instance.recordFlutterFatalError(details);

      // Continua a loggare in console se in debug
      if (kDebugMode) {
        FlutterError.presentError(details);
      }
    };

    // Gestione degli errori asincroni (Dart) al di fuori del ciclo Flutter
    PlatformDispatcher
        .instance
        .onError = (Object error, StackTrace stackTrace) {
      VibraLogger.error(
        'Eccezione Dart Asincrona catturata dal GlobalErrorHandler',
        error: error,
        stackTrace: stackTrace,
        tag: 'GlobalErrorHandler',
      );

      // In produzione: FirebaseCrashlytics.instance.recordError(error, stackTrace, fatal: true);

      // Evita che l'eccezione si propaghi causando crash fatali a basso livello
      return true;
    };
  }
}
