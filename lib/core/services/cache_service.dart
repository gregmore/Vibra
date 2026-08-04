import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/logger.dart';

/// Servizio per la gestione del Caching Offline (Stale-While-Revalidate).
class CacheService {
  static const String keyEvents = 'CACHE_EVENTS';
  static const String keyMusicProfile = 'CACHE_MUSIC_PROFILE';

  static SharedPreferences? _prefs;

  /// Inizializza il servizio (da chiamare in main.dart)
  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    VibraLogger.debug('CacheService inizializzato', tag: 'Cache');
  }

  /// Salva una lista di JSON in cache.
  static Future<void> saveList(
    String key,
    List<Map<String, dynamic>> data,
  ) async {
    if (_prefs == null) return;
    try {
      final jsonString = jsonEncode(data);
      await _prefs!.setString(key, jsonString);
      VibraLogger.debug('Dati salvati in cache per chiave: $key', tag: 'Cache');
    } catch (e) {
      VibraLogger.warning('Errore nel salvataggio in cache: $e', tag: 'Cache');
    }
  }

  /// Recupera una lista di JSON dalla cache.
  static List<Map<String, dynamic>>? getList(String key) {
    if (_prefs == null) return null;

    final jsonString = _prefs!.getString(key);
    if (jsonString == null) return null;

    try {
      final decoded = jsonDecode(jsonString) as List<dynamic>;
      return decoded.map((e) => e as Map<String, dynamic>).toList();
    } catch (e) {
      VibraLogger.warning('Errore nella lettura della cache: $e', tag: 'Cache');
      return null;
    }
  }

  /// Salva un oggetto singolo in cache.
  static Future<void> saveObject(String key, Map<String, dynamic> data) async {
    if (_prefs == null) return;
    try {
      final jsonString = jsonEncode(data);
      await _prefs!.setString(key, jsonString);
      VibraLogger.debug(
        'Oggetto salvato in cache per chiave: $key',
        tag: 'Cache',
      );
    } catch (e) {
      VibraLogger.warning(
        'Errore nel salvataggio oggetto in cache: $e',
        tag: 'Cache',
      );
    }
  }

  /// Recupera un oggetto singolo dalla cache.
  static Map<String, dynamic>? getObject(String key) {
    if (_prefs == null) return null;

    final jsonString = _prefs!.getString(key);
    if (jsonString == null) return null;

    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      VibraLogger.warning(
        'Errore nella lettura oggetto dalla cache: $e',
        tag: 'Cache',
      );
      return null;
    }
  }

  /// Pulisce tutta la cache (es: al logout)
  static Future<void> clearAll() async {
    if (_prefs != null) {
      await _prefs!.clear();
    }
    VibraLogger.debug('Tutta la cache è stata svuotata', tag: 'Cache');
  }

  /// Rimuove una singola chiave dalla cache
  static Future<void> remove(String key) async {
    await _prefs?.remove(key);
    VibraLogger.debug('Chiave $key rimossa dalla cache', tag: 'Cache');
  }
}
