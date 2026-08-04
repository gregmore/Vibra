/// Chiavi utilizzate per salvare dati in SharedPreferences.
class StorageKeys {
  StorageKeys._();

  /// Se l'utente ha completato l'onboarding.
  static const String onboardingCompleted = 'onboarding_completed';

  /// ID dell'utente loggato (cache locale).
  static const String userId = 'user_id';

  /// Timestamp dell'ultimo sync del profilo musicale.
  static const String lastMusicSync = 'last_music_sync';

  /// Raggio di ricerca eventi selezionato dall'utente (in km).
  static const String searchRadius = 'search_radius';

  /// Preferenza notifiche eventi.
  static const String notifyEvents = 'notify_events';

  /// Preferenza notifiche match utenti.
  static const String notifyMatches = 'notify_matches';

  /// Preferenza notifiche richieste amicizia.
  static const String notifyFriendRequests = 'notify_friend_requests';

  /// Token FCM per push notifications.
  static const String fcmToken = 'fcm_token';

  /// Ultima posizione GPS nota (latitudine).
  static const String lastLatitude = 'last_latitude';

  /// Ultima posizione GPS nota (longitudine).
  static const String lastLongitude = 'last_longitude';

  // ── Secure storage (token sensibili) ──────────────────────
  static const String spotifyAccessToken = 'secure_spotify_access_token';
  static const String spotifyRefreshToken = 'secure_spotify_refresh_token';
}
