import '../../domain/entities/spotify_session.dart';

/// Response of `spotify-token-exchange` (no tokens; see [SpotifySession]).
class SpotifyTokenModel extends SpotifySession {
  const SpotifyTokenModel({required super.expiresIn, super.scope});

  factory SpotifyTokenModel.fromJson(Map<String, dynamic> json) {
    final expires = json['expires_in'];
    return SpotifyTokenModel(
      expiresIn: expires is num ? expires.toInt() : 3600,
      scope: json['scope'] as String?,
    );
  }
}
