// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'spotify_playlist_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SpotifyPlaylistModel _$SpotifyPlaylistModelFromJson(
  Map<String, dynamic> json,
) => _SpotifyPlaylistModel(
  id: json['id'] as String,
  name: json['name'] as String,
  tracks: json['tracks'] == null
      ? null
      : SpotifyPlaylistTracksModel.fromJson(
          json['tracks'] as Map<String, dynamic>,
        ),
  images:
      (json['images'] as List<dynamic>?)
          ?.map(
            (e) =>
                SpotifyPlaylistImageModel.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const <SpotifyPlaylistImageModel>[],
);

Map<String, dynamic> _$SpotifyPlaylistModelToJson(
  _SpotifyPlaylistModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'tracks': instance.tracks,
  'images': instance.images,
};

_SpotifyPlaylistTracksModel _$SpotifyPlaylistTracksModelFromJson(
  Map<String, dynamic> json,
) => _SpotifyPlaylistTracksModel(total: (json['total'] as num?)?.toInt());

Map<String, dynamic> _$SpotifyPlaylistTracksModelToJson(
  _SpotifyPlaylistTracksModel instance,
) => <String, dynamic>{'total': instance.total};

_SpotifyPlaylistImageModel _$SpotifyPlaylistImageModelFromJson(
  Map<String, dynamic> json,
) => _SpotifyPlaylistImageModel(
  url: json['url'] as String,
  width: (json['width'] as num?)?.toInt(),
  height: (json['height'] as num?)?.toInt(),
);

Map<String, dynamic> _$SpotifyPlaylistImageModelToJson(
  _SpotifyPlaylistImageModel instance,
) => <String, dynamic>{
  'url': instance.url,
  'width': instance.width,
  'height': instance.height,
};
