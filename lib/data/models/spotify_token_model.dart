import '../../domain/entities/spotify_session.dart';

class SpotifyTokenModel extends SpotifySession {
  const SpotifyTokenModel({
    required super.accessToken,
    required super.refreshToken,
    required super.expiresIn,
    super.scope,
  });

  factory SpotifyTokenModel.fromJson(Map<String, dynamic> json) {
    return SpotifyTokenModel(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      expiresIn: json['expires_in'] as int,
      scope: json['scope'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'expires_in': expiresIn,
      'scope': scope,
    };
  }
}
