import 'package:freezed_annotation/freezed_annotation.dart';

part 'spotify_paged_response.freezed.dart';
part 'spotify_paged_response.g.dart';

/// Risposta paginata tipica di Spotify: { items: [], total, limit, offset, next, previous }
@freezed
abstract class SpotifyPagedResponse with _$SpotifyPagedResponse {
  const factory SpotifyPagedResponse({
    @Default(<dynamic>[]) List<dynamic> items,
    int? total,
    int? limit,
    int? offset,
    String? next,
    String? previous,
  }) = _SpotifyPagedResponse;

  factory SpotifyPagedResponse.fromJson(Map<String, dynamic> json) =>
      _$SpotifyPagedResponseFromJson(json);
}
