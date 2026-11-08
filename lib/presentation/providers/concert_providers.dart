import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/event_recommendation.dart';
import 'core_providers.dart';
import 'location_provider.dart';

/// Current Concert Finder filters.
final concertFiltersProvider = StateProvider.autoDispose<ConcertFilters>(
  (ref) => const ConcertFilters(),
);

/// Recommendations for the given filters. The device position is sent only
/// when it is a real fix (never the browsing fallback).
final concertRecommendationsProvider = FutureProvider.autoDispose
    .family<ConcertRecommendations, ConcertFilters>((ref, filters) async {
      final location = await ref
          .watch(userLocationProvider.future)
          .catchError((_) => UserLocation.milano);
      final device = location.isDeviceLocation;
      return ref
          .watch(supabaseConcertsDatasourceProvider)
          .recommend(
            filters: filters,
            latitude: device ? location.latitude : null,
            longitude: device ? location.longitude : null,
          );
    });
