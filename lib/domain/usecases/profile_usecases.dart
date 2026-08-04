import '../entities/app_user.dart';
import '../entities/music_profile.dart';
import '../repositories/profile_repository.dart';
import 'usecase.dart';

class GetMyProfileUseCase implements UseCase<AppUser, NoParams> {
  GetMyProfileUseCase(this._repository);

  final ProfileRepository _repository;

  @override
  Future<AppUser> call(NoParams params) => _repository.getMyProfile();
}

class UpsertMyProfileUseCase implements UseCase<AppUser, AppUser> {
  UpsertMyProfileUseCase(this._repository);

  final ProfileRepository _repository;

  @override
  Future<AppUser> call(AppUser params) {
    _repository.validateUsername(params.username);
    return _repository.upsertMyProfile(params);
  }
}

class GetMyMusicProfileUseCase implements UseCase<MusicProfile?, NoParams> {
  GetMyMusicProfileUseCase(this._repository);

  final ProfileRepository _repository;

  @override
  Future<MusicProfile?> call(NoParams params) => _repository.getMyMusicProfile();
}

