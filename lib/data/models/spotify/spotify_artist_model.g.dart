// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'spotify_artist_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SpotifyArtistModel _$SpotifyArtistModelFromJson(
  Map<String, dynamic> json,
) => _SpotifyArtistModel(
  id: json['id'] as String,
  name: json['name'] as String,
  genres:
      (json['genres'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  followers: json['followers'] == null
      ? null
      : SpotifyFollowersModel.fromJson(
          json['followers'] as Map<String, dynamic>,
        ),
  images:
      (json['images'] as List<dynamic>?)
          ?.map((e) => SpotifyImageModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <SpotifyImageModel>[],
  popularity: (json['popularity'] as num?)?.toInt(),
);

Map<String, dynamic> _$SpotifyArtistModelToJson(_SpotifyArtistModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'genres': instance.genres,
      'followers': instance.followers,
      'images': instance.images,
      'popularity': instance.popularity,
    };

_SpotifyFollowersModel _$SpotifyFollowersModelFromJson(
  Map<String, dynamic> json,
) => _SpotifyFollowersModel(total: (json['total'] as num?)?.toInt());

Map<String, dynamic> _$SpotifyFollowersModelToJson(
  _SpotifyFollowersModel instance,
) => <String, dynamic>{'total': instance.total};

_SpotifyImageModel _$SpotifyImageModelFromJson(Map<String, dynamic> json) =>
    _SpotifyImageModel(
      url: json['url'] as String,
      width: (json['width'] as num?)?.toInt(),
      height: (json['height'] as num?)?.toInt(),
    );

Map<String, dynamic> _$SpotifyImageModelToJson(_SpotifyImageModel instance) =>
    <String, dynamic>{
      'url': instance.url,
      'width': instance.width,
      'height': instance.height,
    };
