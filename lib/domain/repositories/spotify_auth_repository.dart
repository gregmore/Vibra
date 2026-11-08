import '../entities/spotify_session.dart';

abstract class SpotifyAuthRepository {
  /// OAuth Authorization Code + PKCE, then server-side code exchange.
  /// [onAuthorized] fires once the user granted access in Spotify.
  Future<SpotifySession> connectAccount({void Function()? onAuthorized});
}
