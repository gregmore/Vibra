import '../entities/spotify_session.dart';

abstract class SpotifyAuthRepository {
  Future<SpotifySession> connectAccount();
  Future<SpotifySession> refreshSession();
}
