// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'spotify_paged_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SpotifyPagedResponse _$SpotifyPagedResponseFromJson(
  Map<String, dynamic> json,
) => _SpotifyPagedResponse(
  items: json['items'] as List<dynamic>? ?? const <dynamic>[],
  total: (json['total'] as num?)?.toInt(),
  limit: (json['limit'] as num?)?.toInt(),
  offset: (json['offset'] as num?)?.toInt(),
  next: json['next'] as String?,
  previous: json['previous'] as String?,
);

Map<String, dynamic> _$SpotifyPagedResponseToJson(
  _SpotifyPagedResponse instance,
) => <String, dynamic>{
  'items': instance.items,
  'total': instance.total,
  'limit': instance.limit,
  'offset': instance.offset,
  'next': instance.next,
  'previous': instance.previous,
};
