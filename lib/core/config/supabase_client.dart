import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../utils/logger.dart';
import 'env_config.dart';
import '../services/secure_local_storage.dart';

/// Bootstrap centralizzato di Supabase.
/// Espone metodi e getter unificati per client, sessione e utente corrente.
class SupabaseBootstrap {
  SupabaseBootstrap._();

  static bool _initialized = false;

  /// Inizializza Supabase con supporto PKCE per i flussi OAuth mobile.
  static Future<void> initialize() async {
    if (_initialized) return;

    await Supabase.initialize(
      url: EnvConfig.supabaseUrl,
      publishableKey: EnvConfig.supabaseAnonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
        localStorage: SecureLocalStorage(),
      ),
      realtimeClientOptions: const RealtimeClientOptions(
        logLevel: RealtimeLogLevel.info,
      ),
      storageOptions: const StorageClientOptions(
        retryAttempts: 3,
      ),
      debug: kDebugMode,
    );

    _initialized = true;
    VibraLogger.info('Supabase pronto');
  }

  static SupabaseClient get client => Supabase.instance.client;

  static GoTrueClient get auth => client.auth;

  static User? get currentUser => auth.currentUser;

  static Session? get currentSession => auth.currentSession;

  static bool get isAuthenticated => currentUser != null;
}
