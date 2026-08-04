import 'dart:developer' as dev;

/// Logger strutturato per Vibra con livelli di severità.
/// Wrappa dart:developer per output formattato nella console di debug.
class VibraLogger {
  VibraLogger._();

  static const String _tag = 'Vibra';

  /// Log di debug — visibile solo in modalità debug.
  static void debug(String message, {String? tag}) {
    dev.log(
      message,
      name: tag ?? _tag,
      level: 500, // FINE
    );
  }

  /// Log informativo — eventi normali dell'app.
  static void info(String message, {String? tag}) {
    dev.log(
      message,
      name: tag ?? _tag,
      level: 800, // INFO
    );
  }

  /// Log di avviso — situazioni anomale ma non critiche.
  static void warning(String message, {String? tag}) {
    dev.log(
      message,
      name: tag ?? _tag,
      level: 900, // WARNING
    );
  }

  /// Log di errore — errori che richiedono attenzione.
  static void error(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    dev.log(
      message,
      name: tag ?? _tag,
      level: 1000, // SEVERE
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Log per chiamate API — traccia le richieste HTTP.
  static void api(String method, String url, {int? statusCode}) {
    final status = statusCode != null ? ' → $statusCode' : '';
    dev.log('$method $url$status', name: '$_tag API', level: 500);
  }

  /// Log per navigazione — traccia i cambi di schermata.
  static void navigation(String route) {
    dev.log(route, name: '$_tag Nav', level: 500);
  }
}
