// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'music_profile_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MusicProfileModel _$MusicProfileModelFromJson(Map<String, dynamic> json) =>
    _MusicProfileModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      topArtists:
          (json['top_artists'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          const <Map<String, dynamic>>[],
      topTracks:
          (json['top_tracks'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          const <Map<String, dynamic>>[],
      topGenres:
          (json['top_genres'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          const <Map<String, dynamic>>[],
      lastSyncedAt: json['last_synced_at'] == null
          ? null
          : DateTime.parse(json['last_synced_at'] as String),
    );

Map<String, dynamic> _$MusicProfileModelToJson(_MusicProfileModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'top_artists': instance.topArtists,
      'top_tracks': instance.topTracks,
      'top_genres': instance.topGenres,
      'last_synced_at': instance.lastSyncedAt?.toIso8601String(),
    };
