import 'package:freezed_annotation/freezed_annotation.dart';

part 'spotify_artist_model.freezed.dart';
part 'spotify_artist_model.g.dart';

@freezed
abstract class SpotifyArtistModel with _$SpotifyArtistModel {
  const factory SpotifyArtistModel({
    required String id,
    required String name,
    @Default(<String>[]) List<String> genres,
    @JsonKey(name: 'followers') SpotifyFollowersModel? followers,
    @JsonKey(name: 'images') @Default(<SpotifyImageModel>[])
    List<SpotifyImageModel> images,
    int? popularity,
  }) = _SpotifyArtistModel;

  factory SpotifyArtistModel.fromJson(Map<String, dynamic> json) =>
      _$SpotifyArtistModelFromJson(json);
}

@freezed
abstract class SpotifyFollowersModel with _$SpotifyFollowersModel {
  const factory SpotifyFollowersModel({
    int? total,
  }) = _SpotifyFollowersModel;

  factory SpotifyFollowersModel.fromJson(Map<String, dynamic> json) =>
      _$SpotifyFollowersModelFromJson(json);
}

@freezed
abstract class SpotifyImageModel with _$SpotifyImageModel {
  const factory SpotifyImageModel({
    required String url,
    int? width,
    int? height,
  }) = _SpotifyImageModel;

  factory SpotifyImageModel.fromJson(Map<String, dynamic> json) =>
      _$SpotifyImageModelFromJson(json);
}

