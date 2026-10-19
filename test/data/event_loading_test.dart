import 'package:vibra/presentation/providers/app_state_providers.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vibra/domain/entities/event.dart';
import 'package:vibra/domain/usecases/events_usecases.dart';
import 'package:vibra/presentation/providers/map_events_provider.dart';
import 'package:vibra/presentation/providers/usecase_providers.dart';

class Stored implements GetStoredNearbyEventsUseCase {
  final result = Completer<List<Event>>();
  @override
  Future<List<Event>> call(GetStoredNearbyEventsParams params) => result.future;
}

class External implements SearchNearbyEventsUseCase {
  final result = Completer<List<Event>>();
  @override
  Future<List<Event>> call(SearchNearbyEventsParams params) => result.future;
}

class FeedStored implements GetStoredEventsUseCase {
  final result = Completer<List<Event>>();
  int calls = 0;
  @override
  Future<List<Event>> call(int limit) {
    calls++;
    return result.future;
  }
}

Event event(String id) => Event(
  id: id,
  externalId: id,
  source: 'test',
  name: id,
  eventDate: DateTime(2030),
  latitude: 45,
  longitude: 9,
);

void main() {
  testWidgets(
    'Home publishes database events before external enrichment and deduplicates refresh',
    (tester) async {
      final stored = FeedStored();
      final external = External();
      final container = ProviderContainer(
        overrides: [
          getStoredEventsUseCaseProvider.overrideWithValue(stored),
          searchNearbyEventsUseCaseProvider.overrideWithValue(external),
        ],
      );
      container.read(allEventsProvider);
      await tester.pump();
      container.read(allEventsProvider.notifier).refresh();
      stored.result.complete([event('home-db')]);
      await tester.pump();
      expect(stored.calls, 1);
      expect(external.result.isCompleted, isFalse);
      expect(container.read(allEventsProvider).single.id, 'home-db');
      container.dispose();
      external.result.complete([]);
      await tester.pump();
    },
  );

  testWidgets(
    'Map publishes database events while external search is pending',
    (tester) async {
      final stored = Stored();
      final external = External();
      final container = ProviderContainer(
        overrides: [
          getStoredNearbyEventsUseCaseProvider.overrideWithValue(stored),
          searchNearbyEventsUseCaseProvider.overrideWithValue(external),
        ],
      );
      final sub = container.listen(mapEventsProvider, (_, _) {});
      addTearDown(() {
        sub.close();
        container.dispose();
      });
      await tester.pump();
      container.read(mapEventsProvider.notifier).updateLocation(45, 9, 25000);
      await tester.pump(const Duration(milliseconds: 501));
      stored.result.complete([event('db')]);
      await tester.pump();
      expect(external.result.isCompleted, isFalse);
      expect(container.read(mapEventsProvider).requireValue.single.id, 'db');
      external.result.complete([event('external')]);
      await tester.pump();
      expect(container.read(mapEventsProvider).requireValue.length, 2);
      container.read(mapEventsProvider.notifier).updateLocation(46, 9, 25000);
      expect(container.read(mapEventsProvider).requireValue.length, 2);
      await tester.pump(const Duration(milliseconds: 501));
    },
  );

  testWidgets('Map keeps database events when external search fails', (
    tester,
  ) async {
    final stored = Stored();
    final external = External();
    final container = ProviderContainer(
      overrides: [
        getStoredNearbyEventsUseCaseProvider.overrideWithValue(stored),
        searchNearbyEventsUseCaseProvider.overrideWithValue(external),
      ],
    );
    final sub = container.listen(mapEventsProvider, (_, _) {});
    addTearDown(() {
      sub.close();
      container.dispose();
    });
    await tester.pump();
    container.read(mapEventsProvider.notifier).updateLocation(45, 9, 25000);
    await tester.pump(const Duration(milliseconds: 501));
    stored.result.complete([event('db')]);
    await tester.pump();
    external.result.completeError(Exception('unavailable'));
    await tester.pump();
    expect(container.read(mapEventsProvider).requireValue.single.id, 'db');
  });
}
