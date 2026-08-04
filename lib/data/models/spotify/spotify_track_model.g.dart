// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'spotify_track_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SpotifyTrackModel _$SpotifyTrackModelFromJson(Map<String, dynamic> json) =>
    _SpotifyTrackModel(
      id: json['id'] as String,
      name: json['name'] as String,
      artists:
          (json['artists'] as List<dynamic>?)
              ?.map(
                (e) =>
                    SpotifyTrackArtistModel.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const <SpotifyTrackArtistModel>[],
      popularity: (json['popularity'] as num?)?.toInt(),
    );

Map<String, dynamic> _$SpotifyTrackModelToJson(_SpotifyTrackModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'artists': instance.artists,
      'popularity': instance.popularity,
    };

_SpotifyTrackArtistModel _$SpotifyTrackArtistModelFromJson(
  Map<String, dynamic> json,
) => _SpotifyTrackArtistModel(
  id: json['id'] as String,
  name: json['name'] as String,
);

Map<String, dynamic> _$SpotifyTrackArtistModelToJson(
  _SpotifyTrackArtistModel instance,
) => <String, dynamic>{'id': instance.id, 'name': instance.name};
