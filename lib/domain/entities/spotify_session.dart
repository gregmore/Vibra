/// Entità che rappresenta la sessione di autenticazione Spotify dell'utente.
class SpotifySession {
  const SpotifySession({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    this.scope,
  });

  final String accessToken;
  final String refreshToken;
  final int expiresIn;
  final String? scope;
}
