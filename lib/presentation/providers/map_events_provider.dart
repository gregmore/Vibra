import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/logger.dart';
import '../../domain/entities/event.dart';
import '../../domain/usecases/events_usecases.dart';
import 'usecase_providers.dart';

class MapEventsParams {
  const MapEventsParams({
    required this.latitude,
    required this.longitude,
    required this.radiusMeters,
  });

  final double latitude;
  final double longitude;
  final double radiusMeters;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MapEventsParams &&
          runtimeType == other.runtimeType &&
          latitude == other.latitude &&
          longitude == other.longitude &&
          radiusMeters == other.radiusMeters;

  @override
  int get hashCode => latitude.hashCode ^ longitude.hashCode ^ radiusMeters.hashCode;
}

class MapEventsNotifier extends AutoDisposeAsyncNotifier<List<Event>> {
  Timer? _debounceTimer;
  MapEventsParams? _lastParams;

  @override
  FutureOr<List<Event>> build() {
    ref.onDispose(() {
      _debounceTimer?.cancel();
    });
    return [];
  }

  void updateLocation(double latitude, double longitude, double radiusMeters) {
    final params = MapEventsParams(
      latitude: latitude,
      longitude: longitude,
      radiusMeters: radiusMeters,
    );

    if (_lastParams == params) return;
    _lastParams = params;

    // Debouncing (500ms)
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _fetchEvents(params);
    });
  }

  Future<void> _fetchEvents(MapEventsParams params) async {
    state = const AsyncValue.loading();
    try {
      final usecase = ref.read(searchNearbyEventsUseCaseProvider);
      final events = await usecase(
        SearchNearbyEventsParams(
          latitude: params.latitude,
          longitude: params.longitude,
          radiusKm: (params.radiusMeters / 1000).round(),
        ),
      );
      if (_lastParams == params) {
        state = AsyncValue.data(events);
      }
    } catch (e, st) {
      VibraLogger.error('Errore durante fetch eventi mappa', error: e, stackTrace: st);
      if (_lastParams == params) {
        state = AsyncValue.error(e, st);
      }
    }
  }
}

final mapEventsProvider =
    AutoDisposeAsyncNotifierProvider<MapEventsNotifier, List<Event>>(
  () => MapEventsNotifier(),
);
