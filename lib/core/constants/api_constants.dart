/// URL base e endpoint per le API esterne.
class ApiConstants {
  ApiConstants._();

  // ── Spotify ──────────────────────────────────────────────
  static const String spotifyAuthUrl = 'https://accounts.spotify.com/authorize';
  static const String spotifyTokenUrl = 'https://accounts.spotify.com/api/token';
  static const String spotifyApiBase = 'https://api.spotify.com/v1';
  static const String spotifyTopArtists = '/me/top/artists';
  static const String spotifyTopTracks = '/me/top/tracks';
  static const String spotifyPlaylists = '/me/playlists';
  static const String spotifyMe = '/me';

  /// Scopes OAuth richiesti per analisi gusti musicali.
  static const List<String> spotifyScopes = [
    'user-read-private',
    'user-read-email',
    'user-top-read',
    'user-read-recently-played',
  ];

  /// Redirect URI per OAuth PKCE (deve corrispondere alla config Spotify Dashboard).
  static const String spotifyRedirectUri = 'com.vibra.app://callback';
  static const Duration connectTimeout = Duration(seconds: 20);
  static const Duration receiveTimeout = Duration(seconds: 20);

  // ── Ticketmaster ─────────────────────────────────────────
  static const String ticketmasterApiBase = 'https://app.ticketmaster.com/discovery/v2';
  static const String ticketmasterEvents = '/events.json';

  // ── Songkick ─────────────────────────────────────────────
  static const String songkickApiBase = 'https://api.songkick.com/api/3.0';
  static const String songkickEvents = '/events.json';

  // ── Bandsintown ──────────────────────────────────────────
  static const String bandsintownApiBase = 'https://rest.bandsintown.com';

  /// Costruisce l'URL per gli eventi di un artista su Bandsintown.
  static String bandsintownArtistEvents(String artistName) =>
      '/artists/$artistName/events';
}
