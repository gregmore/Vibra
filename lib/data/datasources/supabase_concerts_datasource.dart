import '../../domain/entities/event.dart';
import '../../domain/entities/event_recommendation.dart';
import '../mappers/domain_mappers.dart';
import '../models/event_model.dart';
import 'supabase_datasource.dart';

/// Concert Intelligence (recommend-events). Location: the device position
/// when it is a real fix; otherwise the server may use the user's own
/// consented location, or none.
class SupabaseConcertsDatasource {
  const SupabaseConcertsDatasource(this._supabase);

  final SupabaseDatasource _supabase;

  static Event? _event(Object? raw) {
    if (raw is! Map) return null;
    try {
      return EventModel.fromJson(Map<String, dynamic>.from(raw)).toEntity();
    } catch (_) {
      return null;
    }
  }

  Future<ConcertRecommendations> recommend({
    ConcertFilters filters = const ConcertFilters(),
    double? latitude,
    double? longitude,
    int limit = 30,
  }) async {
    final Map<String, dynamic> response;
    try {
      response = await _supabase.invokeFunction(
        'recommend-events',
        body: {
          'limit': limit,
          'latitude': ?latitude,
          'longitude': ?longitude,
          ...filters.toBody(),
        },
      );
    } catch (e) {
      if ('$e'.contains('music_profile_not_found')) {
        return const ConcertRecommendations(
          events: [],
          origin: RecommendationOrigin.none,
          needsMusicProfile: true,
        );
      }
      rethrow;
    }
    return ConcertRecommendations(
      origin: switch (response['location_source']) {
        'request' => RecommendationOrigin.device,
        'saved' => RecommendationOrigin.saved,
        _ => RecommendationOrigin.none,
      },
      events: [
        for (final item in (response['data'] as List? ?? const []))
          if (item is Map)
            if (_event(item['event']) case final event?)
              RecommendedEvent(
                event: event,
                relevance:
                    ((item['score'] as Map?)?['compatibility'] as num?)
                        ?.round() ??
                    0,
                reasons: [
                  for (final r in (item['reasons'] as List? ?? const []))
                    ?EventReason.fromJson(r),
                ],
                families: [
                  for (final f in (item['families'] as List? ?? const []))
                    if (f is String) f,
                ],
                distanceKm: (item['distance_km'] as num?)?.toDouble(),
                saved: item['saved'] == true,
              ),
      ],
    );
  }
}
