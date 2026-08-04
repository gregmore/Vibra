import 'package:freezed_annotation/freezed_annotation.dart';

part 'spotify_playlist_model.freezed.dart';
part 'spotify_playlist_model.g.dart';

@freezed
abstract class SpotifyPlaylistModel with _$SpotifyPlaylistModel {
  const factory SpotifyPlaylistModel({
    required String id,
    required String name,
    @JsonKey(name: 'tracks') SpotifyPlaylistTracksModel? tracks,
    @JsonKey(name: 'images')
    @Default(<SpotifyPlaylistImageModel>[])
    List<SpotifyPlaylistImageModel> images,
  }) = _SpotifyPlaylistModel;

  factory SpotifyPlaylistModel.fromJson(Map<String, dynamic> json) =>
      _$SpotifyPlaylistModelFromJson(json);
}

@freezed
abstract class SpotifyPlaylistTracksModel with _$SpotifyPlaylistTracksModel {
  const factory SpotifyPlaylistTracksModel({int? total}) =
      _SpotifyPlaylistTracksModel;

  factory SpotifyPlaylistTracksModel.fromJson(Map<String, dynamic> json) =>
      _$SpotifyPlaylistTracksModelFromJson(json);
}

@freezed
abstract class SpotifyPlaylistImageModel with _$SpotifyPlaylistImageModel {
  const factory SpotifyPlaylistImageModel({
    required String url,
    int? width,
    int? height,
  }) = _SpotifyPlaylistImageModel;

  factory SpotifyPlaylistImageModel.fromJson(Map<String, dynamic> json) =>
      _$SpotifyPlaylistImageModelFromJson(json);
}
