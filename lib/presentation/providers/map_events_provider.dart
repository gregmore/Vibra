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
  int get hashCode =>
      latitude.hashCode ^ longitude.hashCode ^ radiusMeters.hashCode;
}

class MapEventsNotifier extends AutoDisposeAsyncNotifier<List<Event>> {
  Timer? _debounceTimer;
  MapEventsParams? _lastParams;
  bool _disposed = false;

  @override
  FutureOr<List<Event>> build() {
    ref.onDispose(() {
      _disposed = true;
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

    if (!_disposed && _lastParams == params) return;
    _lastParams = params;

    // Debouncing (500ms)
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _fetchEvents(params);
    });
  }

  Future<void> refresh() async {
    final params = _lastParams;
    if (params != null) await _fetchEvents(params);
  }

  Future<void> _fetchEvents(MapEventsParams params) async {
    final previous = state.valueOrNull;
    if (previous == null || previous.isEmpty) {
      state = const AsyncValue.loading();
    }
    final partial = <Event>[];
    void publish(List<Event> events) {
      partial.addAll(events);
      if (!_disposed && _lastParams == params && partial.isNotEmpty) {
        state = AsyncValue.data(_mergeEvents(partial));
      }
    }

    try {
      final storedFuture = ref
          .read(getStoredNearbyEventsUseCaseProvider)(
            GetStoredNearbyEventsParams(
              latitude: params.latitude,
              longitude: params.longitude,
              radiusMeters: params.radiusMeters,
            ),
          )
          .then((events) {
            publish(events);
            return events;
          });

      final externalFuture = ref
          .read(searchNearbyEventsUseCaseProvider)(
            SearchNearbyEventsParams(
              latitude: params.latitude,
              longitude: params.longitude,
              radiusKm: (params.radiusMeters / 1000).round(),
            ),
          )
          .then((events) {
            publish(events);
            return events;
          })
          .catchError((Object error, StackTrace stackTrace) {
            VibraLogger.warning(
              'Sorgenti eventi esterne non disponibili: $error',
              tag: 'MapEvents',
            );
            return <Event>[];
          });

      final results = await Future.wait([storedFuture, externalFuture]);
      final events = _mergeEvents(results.expand((items) => items));

      if (!_disposed && _lastParams == params) {
        state = AsyncValue.data(events);
      }
    } catch (e, st) {
      VibraLogger.error(
        'Errore durante fetch eventi mappa',
        error: e,
        stackTrace: st,
      );
      if (!_disposed && _lastParams == params) {
        if (partial.isNotEmpty) {
          state = AsyncValue.data(_mergeEvents(partial));
        } else if (previous != null && previous.isNotEmpty) {
          state = AsyncValue.data(previous);
        } else {
          state = AsyncValue.error(e, st);
        }
      }
    }
  }

  List<Event> _mergeEvents(Iterable<Event> events) {
    final unique = <String, Event>{};

    for (final event in events) {
      if (event.latitude == null || event.longitude == null) continue;

      final externalKey = event.externalId.trim().toLowerCase();
      final fallbackKey = [
        event.name.trim().toLowerCase(),
        event.venueName?.trim().toLowerCase() ?? '',
        event.eventDate.toUtc().toIso8601String(),
      ].join('|');
      final key = externalKey.isNotEmpty ? externalKey : fallbackKey;
      unique.putIfAbsent(key, () => event);
    }

    final merged = unique.values.toList(growable: false);
    merged.sort((a, b) => a.eventDate.compareTo(b.eventDate));
    return merged;
  }
}

final mapEventsProvider =
    AutoDisposeAsyncNotifierProvider<MapEventsNotifier, List<Event>>(
      () => MapEventsNotifier(),
    );
