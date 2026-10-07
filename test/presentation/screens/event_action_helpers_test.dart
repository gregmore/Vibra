import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:vibra/domain/entities/event.dart';
import 'package:vibra/presentation/screens/event_detail/event_action_helpers.dart';

void main() {
  setUpAll(() => initializeDateFormatting());
  Event event({
    String? url,
    String? status,
    double? latitude,
    double? longitude,
    String? venue,
    String? city,
  }) => Event(
    id: 'event',
    externalId: 'event',
    source: 'test',
    name: 'Concerto',
    eventDate: DateTime(2026, 10, 20, 21),
    ticketUrl: url,
    status: status,
    latitude: latitude,
    longitude: longitude,
    venueName: venue,
    city: city,
  );

  test('Ticket links require a valid web address and available sales', () {
    expect(
      eventTicketUri(event(url: ' https://tickets.example/show ')).toString(),
      'https://tickets.example/show',
    );
    for (final url in [
      '',
      '/show',
      'https:',
      'javascript:alert(1)',
      'file:///tmp/tickets',
    ]) {
      expect(eventTicketUri(event(url: url)), isNull);
    }
    for (final status in ['canceled', 'cancelled', 'offsale']) {
      expect(
        eventTicketUri(
          event(url: 'https://tickets.example/show', status: status),
        ),
        isNull,
      );
    }
  });

  test('Only complete and valid coordinates produce an exact location', () {
    expect(eventCoordinates(event()), isNull);
    expect(eventCoordinates(event(latitude: 45)), isNull);
    expect(eventCoordinates(event(latitude: double.nan, longitude: 9)), isNull);
    expect(eventCoordinates(event(latitude: 91, longitude: 9)), isNull);
    expect(eventCoordinates(event(latitude: 45, longitude: 181)), isNull);
    expect(eventCoordinates(event(latitude: 0, longitude: 0)), (
      latitude: 0.0,
      longitude: 0.0,
    ));
  });

  test(
    'Directions use exact coordinates or a properly encoded venue address',
    () {
      expect(eventDirectionsUri(event()), isNull);
      expect(
        eventDirectionsUri(
          event(latitude: 45, longitude: 9),
        )!.queryParameters['destination'],
        '45.0,9.0',
      );
      final directions = eventDirectionsUri(
        event(venue: 'Teatro & Arena', city: 'Roma'),
      )!;
      expect(directions.scheme, 'https');
      expect(directions.queryParameters['destination'], 'Teatro & Arena, Roma');
    },
  );

  test(
    'Copied event details omit missing fields and unusable ticket links',
    () {
      final sparse = eventDetailsText(event(), 'it');
      expect(sparse, contains('20 ott 2026'));
      expect(sparse, isNot(contains('null')));
      expect(sparse.split('\n'), hasLength(2));
      final cancelled = eventDetailsText(
        event(
          url: 'https://tickets.example/show',
          status: 'canceled',
          venue: 'Arena',
          city: 'Roma',
        ),
        'en',
      );
      expect(cancelled, contains('Arena · Roma'));
      expect(cancelled, isNot(contains('https://tickets.example/show')));
    },
  );
}
