import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../errors/exceptions.dart';

/// Accesso centralizzato alle variabili d'ambiente.
/// Mantiene le chiavi sensibili fuori dal codice sorgente.
class EnvConfig {
  EnvConfig._();

  static bool _loaded = false;

  // Seeded integration tests can target an isolated local/staging project
  // without rewriting the developer's .env file. These are public client
  // values only; a service-role key must never be passed as a dart-define.
  static const String _e2eSupabaseUrl = String.fromEnvironment(
    'VIBRA_E2E_SUPABASE_URL',
  );
  static const String _e2eSupabaseAnonKey = String.fromEnvironment(
    'VIBRA_E2E_SUPABASE_ANON_KEY',
  );

  /// Carica il file `.env` una sola volta.
  static Future<void> load() async {
    if (_loaded) return;
    await dotenv.load(fileName: '.env.public');
    _loaded = true;
  }

  static String _readRequired(String key) {
    final value = dotenv.env[key]?.trim();
    if (value == null || value.isEmpty) {
      throw ConfigurationException(message: 'Configurazione mancante: $key');
    }
    return value;
  }

  static String? _readOptional(String key) {
    final value = dotenv.env[key]?.trim();
    if (value == null || value.isEmpty) {
      return null;
    }
    return value;
  }

  static bool get isIsolatedTest => _e2eSupabaseUrl.isNotEmpty;

  static String get supabaseUrl => _e2eSupabaseUrl.isNotEmpty
      ? _e2eSupabaseUrl
      : _readRequired('SUPABASE_URL');

  static String get supabaseAnonKey => _e2eSupabaseAnonKey.isNotEmpty
      ? _e2eSupabaseAnonKey
      : _readRequired('SUPABASE_ANON_KEY');

  static String get spotifyClientId => _readRequired('SPOTIFY_CLIENT_ID');

  static String get spotifyRedirectUri =>
      _readOptional('SPOTIFY_REDIRECT_URI') ?? 'com.vibra.app://callback';

  static String? get ticketmasterApiKey => null;

  static String? get songkickApiKey => null;

  static String? get bandsintownAppId => _readOptional('BANDSINTOWN_APP_ID');
}
