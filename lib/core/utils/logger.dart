import 'dart:developer' as dev;

/// Evento diagnostico locale, pensato esclusivamente per le segnalazioni.
class SupportLogEntry {
  const SupportLogEntry({
    required this.timestamp,
    required this.level,
    required this.message,
  });

  final DateTime timestamp;
  final String level;
  final String message;

  Map<String, String> toJson() => {
    'timestamp': timestamp.toUtc().toIso8601String(),
    'level': level,
    'message': message,
  };
}

/// Logger strutturato per Vibra con livelli di severità.
/// Wrappa dart:developer per output formattato nella console di debug.
class VibraLogger {
  VibraLogger._();

  static const String _tag = 'Vibra';
  static const int _maxSupportEntries = 30;
  static final List<SupportLogEntry> _supportEntries = [];
  static String? _lastFailedEndpoint;

  /// Ultimi eventi tecnici ripuliti da segreti: non include header o body HTTP.
  static List<Map<String, String>> get supportLogs =>
      List.unmodifiable(_supportEntries.map((entry) => entry.toJson()));

  static String? get lastFailedEndpoint => _lastFailedEndpoint;
  static String redact(String value) => _redact(value);

  static void clear() {
    _supportEntries.clear();
    _lastFailedEndpoint = null;
  }

  static void _record(String level, String message) {
    final sanitized = _redact(message);
    _supportEntries.add(
      SupportLogEntry(
        timestamp: DateTime.now(),
        level: level,
        message: sanitized,
      ),
    );
    if (_supportEntries.length > _maxSupportEntries) {
      _supportEntries.removeAt(0);
    }
  }

  static String _redact(String value) => value
      .replaceAll(
        RegExp(r'Bearer\s+[^\s,\"\x27]+', caseSensitive: false),
        'Bearer [REDACTED]',
      )
      .replaceAllMapped(
        RegExp(
          r'''(access_token|refresh_token|id_token|code_verifier|password|token|api_?key|client_secret)["']?\s*[:=]\s*["']?[^\s&"',}]+''',
          caseSensitive: false,
        ),
        (match) => '${match.group(1)}=[REDACTED]',
      )
      .replaceAll(
        RegExp(r'eyJ[A-Za-z0-9_-]+\.eyJ[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+'),
        '[REDACTED_JWT]',
      )
      .replaceAll(
        RegExp(r'[0-9a-f]{8}-[0-9a-f-]{27,}', caseSensitive: false),
        '[REDACTED_ID]',
      );

  /// Log di debug — visibile solo in modalità debug.
  static void debug(String message, {String? tag}) {
    _record('debug', message);
    dev.log(
      _redact(message),
      name: tag ?? _tag,
      level: 500, // FINE
    );
  }

  /// Log informativo — eventi normali dell'app.
  static void info(String message, {String? tag}) {
    _record('info', message);
    dev.log(
      _redact(message),
      name: tag ?? _tag,
      level: 800, // INFO
    );
  }

  /// Log di avviso — situazioni anomale ma non critiche.
  static void warning(String message, {String? tag}) {
    _record('warning', message);
    dev.log(
      _redact(message),
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
    _record('error', '$message${error == null ? '' : ': $error'}');
    dev.log(
      _redact(message),
      name: tag ?? _tag,
      level: 1000, // SEVERE
      error: error == null ? null : _redact(error.toString()),
      stackTrace: stackTrace,
    );
  }

  /// Log per chiamate API — traccia le richieste HTTP.
  static void api(String method, String url, {int? statusCode}) {
    if (statusCode != null && statusCode >= 400) {
      _lastFailedEndpoint = _redact(url);
    }
    _record(
      'api',
      '$method ${_redact(url)}${statusCode != null ? ' -> $statusCode' : ''}',
    );
    final status = statusCode != null ? ' → $statusCode' : '';
    dev.log(_redact('$method $url$status'), name: '$_tag API', level: 500);
  }

  static void endpointFailure(String endpoint) {
    _lastFailedEndpoint = _redact(endpoint);
    _record('error', 'Endpoint failure: $_lastFailedEndpoint');
  }

  /// Log per navigazione — traccia i cambi di schermata.
  static void navigation(String route) {
    dev.log(route, name: '$_tag Nav', level: 500);
  }
}
