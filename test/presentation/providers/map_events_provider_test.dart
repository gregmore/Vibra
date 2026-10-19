import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vibra/domain/entities/event.dart';
import 'package:vibra/domain/usecases/events_usecases.dart';
import 'package:vibra/presentation/providers/map_events_provider.dart';
import 'package:vibra/presentation/providers/usecase_providers.dart';

class _Stored implements GetStoredNearbyEventsUseCase {
  final requests = <GetStoredNearbyEventsParams>[];
  final results = <Completer<List<Event>>>[];
  @override
  Future<List<Event>> call(GetStoredNearbyEventsParams params) {
    requests.add(params);
    final pending = Completer<List<Event>>();
    results.add(pending);
    return pending.future;
  }
}

class _External implements SearchNearbyEventsUseCase {
  Future<List<Event>> Function()? result;
  final requests = <SearchNearbyEventsParams>[];
  @override
  Future<List<Event>> call(SearchNearbyEventsParams params) async {
    requests.add(params);
    return result == null ? [] : result!();
  }
}

Event _event(
  String id, {
  String source = 'ticketmaster',
  String? externalId,
  double? latitude = 45,
  double? longitude = 9,
  String? status,
}) => Event(
  id: id,
  externalId: externalId ?? id,
  source: source,
  name: id,
  eventDate: DateTime(2030),
  latitude: latitude,
  longitude: longitude,
  status: status,
);

void main() {
  late _Stored stored;
  late _External external;
  late ProviderContainer container;
  late ProviderSubscription<AsyncValue<List<Event>>> subscription;

  setUp(() {
    stored = _Stored();
    external = _External();
    container = ProviderContainer(
      overrides: [
        getStoredNearbyEventsUseCaseProvider.overrideWithValue(stored),
        searchNearbyEventsUseCaseProvider.overrideWithValue(external),
      ],
    );
    subscription = container.listen(mapEventsProvider, (_, _) {});
  });
  tearDown(() {
    subscription.close();
    container.dispose();
  });

  testWidgets('Returning to the same area cannot publish its stale request', (
    tester,
  ) async {
    await tester.pump();
    final notifier = container.read(mapEventsProvider.notifier);
    notifier.updateLocation(45, 9, 25000);
    await tester.pump(const Duration(milliseconds: 501));
    notifier.updateLocation(46, 10, 25000);
    await tester.pump(const Duration(milliseconds: 501));
    notifier.updateLocation(45, 9, 25000);
    await tester.pump(const Duration(milliseconds: 501));
    stored.results[2].complete([_event('latest')]);
    await tester.pump();
    stored.results[0].complete([_event('stale')]);
    stored.results[1].complete([_event('other-area')]);
    await tester.pump();
    expect(container.read(mapEventsProvider).requireValue.single.id, 'latest');
  });

  testWidgets('Refresh cancels debounce and prevents a duplicate request', (
    tester,
  ) async {
    await tester.pump();
    final notifier = container.read(mapEventsProvider.notifier);
    notifier.updateLocation(45, 9, 25000);
    final refresh = notifier.refresh();
    await tester.pump(const Duration(milliseconds: 600));
    expect(stored.requests, hasLength(1));
    stored.results.single.complete([_event('live')]);
    await refresh;
    expect(container.read(mapEventsProvider).requireValue.single.id, 'live');
  });

  testWidgets(
    'Deduplication preserves source and case-sensitive external ids',
    (tester) async {
      await tester.pump();
      container.read(mapEventsProvider.notifier).updateLocation(45, 9, 25000);
      await tester.pump(const Duration(milliseconds: 501));
      stored.results.single.complete([
        _event('tm', externalId: 'ABC'),
        _event('duplicate', source: ' TicketMaster ', externalId: 'ABC'),
        _event('sk', source: 'songkick', externalId: 'ABC'),
        _event('case-sensitive', externalId: 'abc'),
        _event('nan', latitude: double.nan),
        _event('invalid', longitude: 181),
        _event('missing', latitude: null),
      ]);
      await tester.pump();
      expect(container.read(mapEventsProvider).requireValue.map((e) => e.id), [
        'duplicate',
        'sk',
        'case-sensitive',
      ]);
    },
  );

  testWidgets(
    'Invalid areas never call APIs and external radius covers meters',
    (tester) async {
      await tester.pump();
      final notifier = container.read(mapEventsProvider.notifier);
      notifier.updateLocation(double.nan, 9, 25000);
      notifier.updateLocation(45, 181, 25000);
      notifier.updateLocation(45, 9, -1);
      notifier.updateLocation(45, 9, 99);
      notifier.updateLocation(45, 9, 250001);
      await tester.pump(const Duration(milliseconds: 501));
      expect(stored.requests, isEmpty);
      notifier.updateLocation(45, 9, 1100);
      await tester.pump(const Duration(milliseconds: 501));
      expect(external.requests.single.radiusKm, 2);
      stored.results.single.complete([]);
      await tester.pump();
    },
  );

  testWidgets('A failed new area cannot be labelled with the old area events', (
    tester,
  ) async {
    await tester.pump();
    final notifier = container.read(mapEventsProvider.notifier);
    notifier.updateLocation(45, 9, 25000);
    await tester.pump(const Duration(milliseconds: 501));
    stored.results[0].complete([_event('old-area')]);
    await tester.pump();
    notifier.updateLocation(46, 10, 25000);
    await tester.pump(const Duration(milliseconds: 501));
    expect(container.read(mapEventsProvider).isLoading, isTrue);
    expect(container.read(mapEventsProvider).valueOrNull, isEmpty);
    stored.results[1].completeError(Exception('offline'));
    await tester.pump();
    expect(container.read(mapEventsProvider).hasError, isTrue);
    expect(container.read(mapEventsProvider).valueOrNull, isEmpty);
  });
  testWidgets('Fresh cancellation replaces an old onsale marker', (
    tester,
  ) async {
    await tester.pump();
    final live = Completer<List<Event>>();
    external.result = () => live.future;
    container.read(mapEventsProvider.notifier).updateLocation(45, 9, 25000);
    await tester.pump(const Duration(milliseconds: 501));
    stored.results.single.complete([
      _event('old', externalId: 'same', status: 'onsale'),
    ]);
    await tester.pump();
    expect(container.read(mapEventsProvider).requireValue, hasLength(1));
    live.complete([_event('current', externalId: 'same', status: 'canceled')]);
    await tester.pump();
    expect(container.read(mapEventsProvider).requireValue, isEmpty);
  });

  testWidgets('Provider outage cannot masquerade as an empty catalogue', (
    tester,
  ) async {
    await tester.pump();
    external.result = () => Future.error(Exception('provider unavailable'));
    container.read(mapEventsProvider.notifier).updateLocation(45, 9, 25000);
    await tester.pump(const Duration(milliseconds: 501));
    stored.results.single.complete([]);
    await tester.pump();
    expect(container.read(mapEventsProvider).hasError, isTrue);
  });
}
