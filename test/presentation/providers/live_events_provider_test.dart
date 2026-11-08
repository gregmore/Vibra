import 'package:flutter_test/flutter_test.dart';
import 'package:vibra/domain/entities/event.dart';
import 'package:vibra/presentation/providers/live_events_provider.dart';
import 'package:vibra/presentation/providers/location_provider.dart';

void main() {
  final now = DateTime.utc(2026, 10, 13, 20);
  Event event(
    String id, {
    double? latitude = 45.4642,
    double? longitude = 9.19,
    DateTime? date,
    String? status,
  }) => Event(
    id: id,
    externalId: id,
    source: 'ticketmaster',
    name: id,
    eventDate: date ?? now,
    latitude: latitude,
    longitude: longitude,
    status: status,
  );
  const location = UserLocation(latitude: 45.4642, longitude: 9.19);

  test('Browsing fallback cannot grant Live eligibility', () {
    expect(
      eligibleLiveEvents(
        events: [event('nearby')],
        location: UserLocation.milano,
        now: now,
      ),
      isEmpty,
    );
  });

  test('Live requires valid coordinates, ±24 hours and actual proximity', () {
    final result = eligibleLiveEvents(
      events: [
        event('far', latitude: 46),
        event('near', latitude: 45.465),
        event('no-location', latitude: null),
        event('invalid-location', longitude: double.nan),
        event('tomorrow', date: now.add(const Duration(hours: 25))),
        event('expired', date: now.subtract(const Duration(hours: 25))),
        event('cancelled', status: 'cancelled'),
        event('closest'),
        event('yesterday', date: now.subtract(const Duration(hours: 23))),
      ],
      location: location,
      now: now,
    );
    expect(result.map((e) => e.id), ['yesterday', 'closest', 'near']);
  });

  test('Invalid device coordinates cannot unlock chat', () {
    expect(
      eligibleLiveEvents(
        events: [event('near')],
        location: const UserLocation(latitude: 91, longitude: 9.19),
        now: now,
      ),
      isEmpty,
    );
  });

  test('Ticket sales ending does not close the chat during a concert', () {
    expect(
      eligibleLiveEvents(
        events: [event('concert', status: 'offsale')],
        location: location,
        now: now,
      ).single.id,
      'concert',
    );
  });
}
