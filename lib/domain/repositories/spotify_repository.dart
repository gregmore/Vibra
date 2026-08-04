import '../entities/music_profile.dart';

abstract class SpotifyRepository {
  Future<void> authenticate();

  Future<void> loadTokensIntoDatasource();

  Future<MusicProfile> buildMusicProfilePayload({
    required String userId,
  });

  Future<void> refreshTokenIfPossible();
}

