import '../../core/errors/exceptions.dart';
import '../../domain/entities/event.dart';
import '../../domain/entities/music_radar.dart';
import '../mappers/domain_mappers.dart';
import '../models/event_model.dart';
import 'supabase_datasource.dart';

/// Music Radar (docs/music-radar.md). Locations never reach the app: the
/// server answers with people inside the radius and aggregates only.
class SupabaseMusicRadarDatasource {
  const SupabaseMusicRadarDatasource(this._supabase);

  final SupabaseDatasource _supabase;

  void _requireUser() {
    if (_supabase.currentUser == null) {
      throw const AuthException(message: 'Utente non autenticato');
    }
  }

  static Event? _event(Map<String, dynamic> row) {
    try {
      return EventModel.fromJson(row).toEntity();
    } catch (_) {
      return null;
    }
  }

  Future<MusicRadar> radar() async {
    _requireUser();
    final result = await _supabase.client.rpc('get_music_radar');
    return MusicRadar.fromJson(result, parseEvent: _event);
  }

  Future<void> updateSettings({
    bool? enabled,
    bool? visible,
    int? distanceKm,
    RadarPrecision? precision,
  }) async {
    _requireUser();
    await _supabase.client.rpc(
      'set_music_radar_settings',
      params: {
        'p_enabled': enabled,
        'p_visible': visible,
        'p_distance_km': distanceKm,
        'p_precision': precision?.name,
      },
    );
  }
}
