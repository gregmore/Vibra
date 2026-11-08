/// Outcome of a Spotify connection.
///
/// Spotify access and refresh tokens never reach the device: they are stored
/// encrypted on the server (`spotify_connections`) and used only by Edge
/// Functions, which also refresh them. The app only learns that the account
/// is connected, the granted scopes and the access-token lifetime.
class SpotifySession {
  const SpotifySession({required this.expiresIn, this.scope});

  final int expiresIn;
  final String? scope;

  List<String> get scopes =>
      (scope ?? '').split(' ').where((s) => s.isNotEmpty).toList();
}
