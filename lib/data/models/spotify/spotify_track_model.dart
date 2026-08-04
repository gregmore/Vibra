import 'package:freezed_annotation/freezed_annotation.dart';

part 'spotify_track_model.freezed.dart';
part 'spotify_track_model.g.dart';

@freezed
abstract class SpotifyTrackModel with _$SpotifyTrackModel {
  const factory SpotifyTrackModel({
    required String id,
    required String name,
    @JsonKey(name: 'artists') @Default(<SpotifyTrackArtistModel>[])
    List<SpotifyTrackArtistModel> artists,
    int? popularity,
  }) = _SpotifyTrackModel;

  factory SpotifyTrackModel.fromJson(Map<String, dynamic> json) =>
      _$SpotifyTrackModelFromJson(json);
}

@freezed
abstract class SpotifyTrackArtistModel with _$SpotifyTrackArtistModel {
  const factory SpotifyTrackArtistModel({
    required String id,
    required String name,
  }) = _SpotifyTrackArtistModel;

  factory SpotifyTrackArtistModel.fromJson(Map<String, dynamic> json) =>
      _$SpotifyTrackArtistModelFromJson(json);
}

