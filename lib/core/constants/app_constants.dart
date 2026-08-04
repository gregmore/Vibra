/// Valori costanti utilizzati in tutta l'app.
class AppConstants {
  AppConstants._();

  // ── App ──────────────────────────────────────────────────
  static const String appName = 'Vibra';
  static const String appSlogan = 'Non ascoltare la musica. Vivila.';
  static const String appVersion = '0.1.0';
  static const String appBuildNumber = '1';
  static const String androidPackageName = 'com.vibra.app';
  static const String iOSBundleId = 'com.vibra.app';
  static const String supportEmail = 'support@vibra.app';
  static const String privacyEmail = 'privacy@vibra.app';
  static const String legalEmail = 'legal@vibra.app';

  // ── Raggi di ricerca eventi (in km) ──────────────────────
  static const List<int> searchRadii = [25, 50, 100, 250];
  static const int defaultSearchRadiusKm = 50;

  // ── Paginazione ──────────────────────────────────────────
  static const int defaultPageSize = 20;
  static const int maxPageSize = 50;
  static const int spotifyTopItemsLimit = 50;

  // ── Matching e raccomandazione ────────────────────────────
  /// Soglia minima di score per mostrare un evento nella sezione "Per Te".
  static const int recommendationThreshold = 70;

  /// Pesi dell'algoritmo di raccomandazione eventi.
  static const double weightArtistMatch = 0.50;
  static const double weightGenreMatch = 0.25;
  static const double weightProximity = 0.15;
  static const double weightPopularity = 0.10;

  /// Pesi dell'algoritmo di compatibilità utenti.
  static const double weightUserArtists = 0.60;
  static const double weightUserGenres = 0.40;

  // ── Live Vibra ───────────────────────────────────────────
  /// Raggio massimo (in metri) per attivare la modalità Live.
  static const double liveActivationRadiusMeters = 500;

  /// Ore dopo l'evento in cui la chat live rimane attiva.
  static const int liveChatExpirationHours = 24;

  // ── Cache ────────────────────────────────────────────────
  /// Durata cache profilo musicale (in ore).
  static const int musicProfileCacheHours = 24;

  /// Durata cache eventi (in minuti).
  static const int eventsCacheMinutes = 30;

  // ── Scoring artisti ──────────────────────────────────────
  /// Score massimo per la posizione 1 nei top artisti.
  static const int maxArtistScore = 100;

  /// Formula: score = maxArtistScore - (posizione - 1) * artistScoreDecrement
  static const int artistScoreDecrement = 1;

  // ── UI ────────────────────────────────────────────────────
  static const double cardBorderRadius = 20.0;
  static const double bottomSheetBorderRadius = 24.0;
  static const double buttonBorderRadius = 50.0;
  static const double glassmorphismBlur = 20.0;
  static const double glassmorphismOpacity = 0.15;
  static const double minSupportedWidth = 375.0;
  static const double maxSupportedWidth = 428.0;
}
