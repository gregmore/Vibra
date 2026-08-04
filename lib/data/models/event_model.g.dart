// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_EventModel _$EventModelFromJson(Map<String, dynamic> json) => _EventModel(
  id: json['id'] as String,
  externalId: json['external_id'] as String,
  source: json['source'] as String,
  name: json['name'] as String,
  artistName: json['artist_name'] as String?,
  artistSpotifyId: json['artist_spotify_id'] as String?,
  venueName: json['venue_name'] as String?,
  city: json['city'] as String?,
  country: json['country'] as String?,
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
  eventDate: DateTime.parse(json['event_date'] as String),
  ticketUrl: json['ticket_url'] as String?,
  priceMin: (json['price_min'] as num?)?.toDouble(),
  priceMax: (json['price_max'] as num?)?.toDouble(),
  imageUrl: json['image_url'] as String?,
  description: json['description'] as String?,
  status: json['status'] as String?,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$EventModelToJson(_EventModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'external_id': instance.externalId,
      'source': instance.source,
      'name': instance.name,
      'artist_name': instance.artistName,
      'artist_spotify_id': instance.artistSpotifyId,
      'venue_name': instance.venueName,
      'city': instance.city,
      'country': instance.country,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'event_date': instance.eventDate.toIso8601String(),
      'ticket_url': instance.ticketUrl,
      'price_min': instance.priceMin,
      'price_max': instance.priceMax,
      'image_url': instance.imageUrl,
      'description': instance.description,
      'status': instance.status,
      'created_at': instance.createdAt?.toIso8601String(),
    };
