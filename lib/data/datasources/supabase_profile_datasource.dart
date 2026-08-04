import '../../core/constants/db_tables.dart';
import '../../core/errors/exceptions.dart';
import '../../core/services/cache_service.dart';
import '../../core/utils/logger.dart';
import '../models/music_profile_model.dart';
import '../models/user_model.dart';
import 'supabase_datasource.dart';

/// Datasource Supabase per profilo utente + profilo musicale.
class SupabaseProfileDatasource {
  SupabaseProfileDatasource(this._supabase);

  final SupabaseDatasource _supabase;

  Future<UserModel> getMyUser() async {
    final user = _supabase.currentUser;
    if (user == null) {
      throw const AuthException(message: 'Utente non autenticato');
    }

    try {
      final rows = await _supabase.select(
        DbTables.users,
        filters: {'id': user.id},
        limit: 1,
      );
      if (rows.isEmpty) {
        throw const ServerException(message: 'Profilo utente non trovato');
      }

      final userModel = UserModel.fromJson(rows.first);
      await CacheService.saveObject(
        'CACHE_USER_PROFILE_${user.id}',
        userModel.toJson(),
      );
      return userModel;
    } catch (e) {
      final cachedJson = CacheService.getObject(
        'CACHE_USER_PROFILE_${user.id}',
      );
      if (cachedJson != null) {
        return UserModel.fromJson(cachedJson);
      }
      rethrow;
    }
  }

  Future<UserModel> upsertMyUser(UserModel model) async {
    final user = _supabase.currentUser;
    if (user == null) {
      throw const AuthException(message: 'Utente non autenticato');
    }
    if (model.id != user.id) {
      throw const ServerException(message: 'ID profilo non coerente con auth');
    }

    final row = await _supabase.upsert(
      DbTables.users,
      model.toJson(),
      onConflict: 'id',
    );
    final userModel = UserModel.fromJson(row);
    await CacheService.saveObject(
      'CACHE_USER_PROFILE_${user.id}',
      userModel.toJson(),
    );
    return userModel;
  }

  Future<MusicProfileModel?> getMyMusicProfile() async {
    final user = _supabase.currentUser;
    if (user == null) {
      throw const AuthException(message: 'Utente non autenticato');
    }

    try {
      final rows = await _supabase.select(
        DbTables.musicProfiles,
        filters: {'user_id': user.id},
        limit: 1,
      );
      if (rows.isEmpty) return null;

      final row = Map<String, dynamic>.from(rows.first);

      // Fix potential Freezed TypeErrors with Supabase jsonb arrays
      if (row['top_artists'] is List) {
        row['top_artists'] = (row['top_artists'] as List)
            .map((e) => e is Map ? Map<String, dynamic>.from(e) : e)
            .toList();
      }
      if (row['top_tracks'] is List) {
        row['top_tracks'] = (row['top_tracks'] as List)
            .map((e) => e is Map ? Map<String, dynamic>.from(e) : e)
            .toList();
      }
      if (row['top_genres'] is List) {
        row['top_genres'] = (row['top_genres'] as List)
            .map((e) => e is Map ? Map<String, dynamic>.from(e) : e)
            .toList();
      }

      final profile = MusicProfileModel.fromJson(row);
      await CacheService.saveObject(
        '${CacheService.keyMusicProfile}_${user.id}',
        profile.toJson(),
      );
      return profile;
    } catch (e, st) {
      VibraLogger.error(
        'Failed to parse music profile',
        error: e,
        stackTrace: st,
      );
      final cachedJson = CacheService.getObject(
        '${CacheService.keyMusicProfile}_${user.id}',
      );
      if (cachedJson != null) {
        return MusicProfileModel.fromJson(cachedJson);
      }
      rethrow;
    }
  }

  Future<MusicProfileModel> upsertMyMusicProfile(
    MusicProfileModel model,
  ) async {
    final user = _supabase.currentUser;
    if (user == null) {
      throw const AuthException(message: 'Utente non autenticato');
    }
    if (model.userId != user.id) {
      throw const ServerException(message: 'user_id non coerente con auth');
    }

    final row = await _supabase.upsert(
      DbTables.musicProfiles,
      model.toJson(),
      onConflict: 'user_id',
    );
    final profile = MusicProfileModel.fromJson(row);
    await CacheService.saveObject(
      '${CacheService.keyMusicProfile}_${user.id}',
      profile.toJson(),
    );
    VibraLogger.info('Music profile upsert completato', tag: 'SupabaseProfile');
    return profile;
  }
}
