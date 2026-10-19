import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vibra/data/datasources/events_aggregator_datasource.dart';
import 'package:vibra/data/datasources/supabase_datasource.dart';
import 'package:vibra/data/datasources/supabase_events_datasource.dart';

class _Source extends SupabaseDatasource {
  _Source(this.testClient);
  final SupabaseClient testClient;
  @override
  SupabaseClient get client => testClient;
}

void main() {
  test(
    'Geographic discovery reaches the protected backend and preserves canonical ids',
    () async {
      final requests = <http.Request>[];
      final client = SupabaseClient(
        'https://example.supabase.co',
        'test-key',
        httpClient: MockClient((request) async {
          requests.add(request);
          return http.Response(
            jsonEncode({
              'events': [
                {
                  'id': '70eb0000-0000-0000-0000-000000000001',
                  'source': 'ticketmaster',
                  'external_id': 'real-provider-id',
                  'name': 'A provider concert',
                  'event_date': '2030-05-12T20:00:00Z',
                  'location_lat': 45.4642,
                  'location_lon': 9.19,
                  'status': 'onsale',
                },
              ],
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }),
      );
      addTearDown(client.dispose);
      final datasource = SupabaseEventsDatasource(_Source(client));
      final aggregator = EventsAggregatorDatasource(
        nearbySearch: datasource.searchNearbyEvents,
      );
      final events = await aggregator.searchNearby(
        latitude: 45.4642,
        longitude: 9.19,
        radiusKm: 100,
      );
      expect(requests.single.url.path, '/functions/v1/search-events');
      expect(jsonDecode(requests.single.body), {
        'latitude': 45.4642,
        'longitude': 9.19,
        'radius_km': 100,
      });
      expect(events.single.id, '70eb0000-0000-0000-0000-000000000001');
      expect(events.single.externalId, 'real-provider-id');
      expect(events.single.latitude, 45.4642);
      expect(events.single.longitude, 9.19);
    },
  );

  test(
    'Provider failure is surfaced instead of pretending the area has no events',
    () async {
      final client = SupabaseClient(
        'https://example.supabase.co',
        'test-key',
        httpClient: MockClient(
          (request) async => http.Response(
            jsonEncode({'error': 'event_provider_unavailable'}),
            502,
            headers: {'content-type': 'application/json'},
          ),
        ),
      );
      addTearDown(client.dispose);
      final datasource = SupabaseEventsDatasource(_Source(client));
      final aggregator = EventsAggregatorDatasource(
        nearbySearch: datasource.searchNearbyEvents,
      );
      await expectLater(
        aggregator.searchNearby(latitude: 45.46, longitude: 9.19, radiusKm: 25),
        throwsA(isA<FunctionException>()),
      );
    },
  );
}
