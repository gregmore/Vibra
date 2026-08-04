import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../errors/exceptions.dart';

/// Accesso centralizzato alle variabili d'ambiente.
/// Mantiene le chiavi sensibili fuori dal codice sorgente.
class EnvConfig {
  EnvConfig._();

  static bool _loaded = false;

  /// Carica il file `.env` una sola volta.
  static Future<void> load() async {
    if (_loaded) return;
    await dotenv.load(fileName: '.env');
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

  static String get supabaseUrl => _readRequired('SUPABASE_URL');

  static String get supabaseAnonKey => _readRequired('SUPABASE_ANON_KEY');

  static String get spotifyClientId => _readRequired('SPOTIFY_CLIENT_ID');

  static String get spotifyRedirectUri =>
      _readOptional('SPOTIFY_REDIRECT_URI') ?? 'com.vibra.app://callback';

  static String? get ticketmasterApiKey =>
      _readOptional('TICKETMASTER_API_KEY');

  static String? get songkickApiKey => _readOptional('SONGKICK_API_KEY');

  static String? get bandsintownAppId => _readOptional('BANDSINTOWN_APP_ID');
}
