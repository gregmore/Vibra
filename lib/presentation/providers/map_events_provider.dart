import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/geography.dart';
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
  MapEventsParams? _displayedParams;
  bool _disposed = false;
  int _requestVersion = 0;

  @override
  FutureOr<List<Event>> build() {
    ref.onDispose(() {
      _disposed = true;
      _debounceTimer?.cancel();
    });
    return [];
  }

  void updateLocation(double latitude, double longitude, double radiusMeters) {
    if (_disposed ||
        !areValidCoordinates(latitude, longitude) ||
        !radiusMeters.isFinite ||
        radiusMeters < 100 ||
        radiusMeters > 250000) {
      return;
    }
    final params = MapEventsParams(
      latitude: latitude,
      longitude: longitude,
      radiusMeters: radiusMeters,
    );

    if (_lastParams == params) return;
    _lastParams = params;
    final version = ++_requestVersion;

    // Debouncing (500ms)
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _fetchEvents(params, version);
    });
  }

  Future<void> refresh() async {
    if (_disposed) return;
    _debounceTimer?.cancel();
    final params = _lastParams;
    if (params != null) await _fetchEvents(params, ++_requestVersion);
  }

  Future<void> _fetchEvents(MapEventsParams params, int version) async {
    if (_disposed || version != _requestVersion) return;
    final previous = state.valueOrNull;
    if (_displayedParams != params) {
      // Riverpod carries data into loading/error states. Clear the old area
      // first so its markers cannot remain attached to the new camera center.
      state = const AsyncValue.data([]);
    }
    if (previous == null || previous.isEmpty || _displayedParams != params) {
      state = const AsyncValue.loading();
    }
    final partial = <Event>[];
    void publish(List<Event> events) {
      partial.addAll(events);
      if (!_disposed && version == _requestVersion && partial.isNotEmpty) {
        _displayedParams = params;
        state = AsyncValue.data(_mergeEvents(partial));
      }
    }

    try {
      Object? providerError;
      StackTrace? providerStackTrace;
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
              radiusKm: (params.radiusMeters / 1000).ceil(),
            ),
          )
          .then((events) {
            publish(events);
            return events;
          })
          .catchError((Object error, StackTrace stackTrace) {
            providerError = error;
            providerStackTrace = stackTrace;
            VibraLogger.warning(
              'Sorgenti eventi esterne non disponibili: $error',
              tag: 'MapEvents',
            );
            return <Event>[];
          });

      final results = await Future.wait([storedFuture, externalFuture]);
      final events = _mergeEvents(results.expand((items) => items));
      if (events.isEmpty && providerError != null) {
        Error.throwWithStackTrace(providerError!, providerStackTrace!);
      }

      if (!_disposed && version == _requestVersion) {
        _displayedParams = params;
        state = AsyncValue.data(events);
      }
    } catch (e, st) {
      VibraLogger.error(
        'Errore durante fetch eventi mappa',
        error: e,
        stackTrace: st,
      );
      if (!_disposed && version == _requestVersion) {
        if (partial.isNotEmpty) {
          state = AsyncValue.data(_mergeEvents(partial));
        } else if (_displayedParams == params &&
            previous != null &&
            previous.isNotEmpty) {
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
      if (!areValidCoordinates(event.latitude, event.longitude)) continue;

      final externalId = event.externalId.trim();
      final externalKey = '${event.source.trim().toLowerCase()}:$externalId';
      final fallbackKey = [
        event.name.trim().toLowerCase(),
        event.venueName?.trim().toLowerCase() ?? '',
        event.city?.trim().toLowerCase() ?? '',
        event.eventDate.toUtc().toIso8601String(),
      ].join('|');
      final key = externalId.isNotEmpty ? externalKey : fallbackKey;
      // Fresh provider rows replace stored metadata (including cancellations).
      unique[key] = event;
    }

    final merged = unique.values
        .where(
          (event) => event.status != 'canceled' && event.status != 'postponed',
        )
        .toList(growable: false);
    merged.sort((a, b) => a.eventDate.compareTo(b.eventDate));
    return merged;
  }
}

final mapEventsProvider =
    AutoDisposeAsyncNotifierProvider<MapEventsNotifier, List<Event>>(
      () => MapEventsNotifier(),
    );
