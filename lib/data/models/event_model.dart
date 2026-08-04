import 'package:freezed_annotation/freezed_annotation.dart';

part 'event_model.freezed.dart';
part 'event_model.g.dart';

/// DTO della tabella `public.events`.
@freezed
abstract class EventModel with _$EventModel {
  const factory EventModel({
    required String id,
    @JsonKey(name: 'external_id') required String externalId,
    required String source, // ticketmaster|songkick|bandsintown
    required String name,
    @JsonKey(name: 'artist_name') String? artistName,
    @JsonKey(name: 'artist_spotify_id') String? artistSpotifyId,
    @JsonKey(name: 'venue_name') String? venueName,
    String? city,
    String? country,
    double? latitude,
    double? longitude,
    @JsonKey(name: 'event_date') required DateTime eventDate,
    @JsonKey(name: 'ticket_url') String? ticketUrl,
    @JsonKey(name: 'price_min') double? priceMin,
    @JsonKey(name: 'price_max') double? priceMax,
    @JsonKey(name: 'image_url') String? imageUrl,
    String? description,
    String? status,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _EventModel;

  factory EventModel.fromJson(Map<String, dynamic> json) =>
      _$EventModelFromJson(json);
}

