import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/logger.dart';

class SecureLocalStorage extends LocalStorage {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.unlocked_this_device,
    ),
  );
  final String projectHost;
  String get _supabaseSessionKey => 'supabase_auth_token_$projectHost';

  const SecureLocalStorage({required this.projectHost}) : super();

  @override
  Future<void> initialize() async {
    // Old sessions had a shared key across production and staging. Require a
    // fresh login once instead of restoring an account into the wrong backend.
    await _secureStorage.delete(key: 'supabase_auth_token');
    VibraLogger.debug('SecureLocalStorage inizializzato', tag: 'Auth');
  }

  @override
  Future<bool> hasAccessToken() async {
    final hasToken = await _secureStorage.containsKey(key: _supabaseSessionKey);
    return hasToken;
  }

  @override
  Future<String?> accessToken() async {
    return await _secureStorage.read(key: _supabaseSessionKey);
  }

  @override
  Future<void> removePersistedSession() async {
    await _secureStorage.delete(key: _supabaseSessionKey);
    VibraLogger.debug(
      'Sessione Supabase rimossa da SecureStorage',
      tag: 'Auth',
    );
  }

  @override
  Future<void> persistSession(String persistSessionString) async {
    await _secureStorage.write(
      key: _supabaseSessionKey,
      value: persistSessionString,
    );
    VibraLogger.debug(
      'Sessione Supabase salvata in SecureStorage',
      tag: 'Auth',
    );
  }
}
