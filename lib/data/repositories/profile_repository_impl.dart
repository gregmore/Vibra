import '../../core/errors/exceptions.dart';
import '../../core/utils/logger.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/entities/music_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/supabase_profile_datasource.dart';
import '../mappers/domain_mappers.dart';

/// Repository concreto per profilo utente.
class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this._datasource);

  final SupabaseProfileDatasource _datasource;

  @override
  Future<AppUser> getMyProfile() async {
    final model = await _datasource.getMyUser();
    return model.toEntity();
  }

  @override
  Future<AppUser> upsertMyProfile(AppUser user) async {
    final model = await _datasource.upsertMyUser(user.toModel());
    return model.toEntity();
  }

  @override
  Future<MusicProfile?> getMyMusicProfile() async {
    final model = await _datasource.getMyMusicProfile();
    return model?.toEntity();
  }

  @override
  Future<MusicProfile> upsertMyMusicProfile(MusicProfile profile) async {
    final model = await _datasource.upsertMyMusicProfile(profile.toModel());
    return model.toEntity();
  }

  /// Utility: valida che l'username rispetti regole base.
  @override
  void validateUsername(String username) {
    final normalized = username.trim();
    if (normalized.length < 3) {
      throw const ServerException(message: 'Username troppo corto');
    }
    if (!RegExp(r'^[a-zA-Z0-9_.]+$').hasMatch(normalized)) {
      throw const ServerException(
        message: 'Username non valido (usa solo a-z, 0-9, _ e .)',
      );
    }
    VibraLogger.debug('Username validato: $normalized', tag: 'ProfileRepo');
  }
}
