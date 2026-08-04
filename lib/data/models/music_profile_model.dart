import 'package:freezed_annotation/freezed_annotation.dart';

part 'music_profile_model.freezed.dart';
part 'music_profile_model.g.dart';

/// DTO della tabella `public.music_profiles`.
/// I campi JSONB contengono array strutturati come richiesto dal prompt.
@freezed
abstract class MusicProfileModel with _$MusicProfileModel {
  const factory MusicProfileModel({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'top_artists') @Default(<Map<String, dynamic>>[])
    List<Map<String, dynamic>> topArtists,
    @JsonKey(name: 'top_tracks') @Default(<Map<String, dynamic>>[])
    List<Map<String, dynamic>> topTracks,
    @JsonKey(name: 'top_genres') @Default(<Map<String, dynamic>>[])
    List<Map<String, dynamic>> topGenres,
    @JsonKey(name: 'last_synced_at') DateTime? lastSyncedAt,
  }) = _MusicProfileModel;

  factory MusicProfileModel.fromJson(Map<String, dynamic> json) =>
      _$MusicProfileModelFromJson(json);
}

