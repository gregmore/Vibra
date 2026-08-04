import '../entities/app_user.dart';
import '../entities/music_profile.dart';

abstract class ProfileRepository {
  Future<AppUser> getMyProfile();

  Future<AppUser> upsertMyProfile(AppUser user);

  Future<MusicProfile?> getMyMusicProfile();

  Future<MusicProfile> upsertMyMusicProfile(MusicProfile profile);

  void validateUsername(String username);
}

