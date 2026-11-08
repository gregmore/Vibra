import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vibra/core/errors/exceptions.dart';
import 'package:vibra/core/services/cache_service.dart';
import 'package:vibra/data/datasources/supabase_datasource.dart';
import 'package:vibra/data/datasources/supabase_events_datasource.dart';

class _Datasource extends SupabaseDatasource {
  _Datasource(this.testClient);
  final SupabaseClient testClient;
  @override
  SupabaseClient get client => testClient;
}

void main() {
  test('Offline map cache belongs to the requested area and radius', () async {
    SharedPreferences.setMockInitialValues({});
    await CacheService.initialize();
    var offline = false;
    final client = SupabaseClient(
      'https://test.supabase.co',
      'test-key',
      httpClient: MockClient((request) async {
        if (offline) return http.Response('offline', 503, request: request);
        return http.Response(
          jsonEncode([
            {
              'id': 'rome',
              'external_id': 'rome',
              'source': 'ticketmaster',
              'name': 'Concerto a Roma',
              'event_date': DateTime.now()
                  .add(const Duration(days: 2))
                  .toUtc()
                  .toIso8601String(),
              'location_lat': 41.9,
              'location_lon': 12.5,
            },
          ]),
          200,
          headers: {'content-type': 'application/json'},
          request: request,
        );
      }),
    );
    addTearDown(client.dispose);
    final datasource = SupabaseEventsDatasource(_Datasource(client));
    final online = await datasource.getNearbyEventsWithDistance(
      latitude: 41.9,
      longitude: 12.5,
      radiusMeters: 25000,
    );
    expect(online.single.id, 'rome');
    offline = true;
    final cached = await datasource.getNearbyEventsWithDistance(
      latitude: 41.9,
      longitude: 12.5,
      radiusMeters: 25000,
    );
    expect(cached.single.id, 'rome');
    await expectLater(
      datasource.getNearbyEventsWithDistance(
        latitude: 45.46,
        longitude: 9.19,
        radiusMeters: 25000,
      ),
      throwsA(isA<ServerException>()),
    );
    await expectLater(
      datasource.getNearbyEventsWithDistance(
        latitude: 41.9,
        longitude: 12.5,
        radiusMeters: 100000,
      ),
      throwsA(isA<ServerException>()),
    );
  });

  test('An empty search is a usable offline cache for the same area', () async {
    SharedPreferences.setMockInitialValues({});
    await CacheService.initialize();
    var offline = false;
    final client = SupabaseClient(
      'https://test.supabase.co',
      'test-key',
      httpClient: MockClient((request) async {
        if (offline) return http.Response('offline', 503, request: request);
        return http.Response(
          '[]',
          200,
          headers: {'content-type': 'application/json'},
          request: request,
        );
      }),
    );
    addTearDown(client.dispose);
    final datasource = SupabaseEventsDatasource(_Datasource(client));
    expect(
      await datasource.getNearbyEventsWithDistance(
        latitude: 45,
        longitude: 9,
        radiusMeters: 25000,
      ),
      isEmpty,
    );
    offline = true;
    expect(
      await datasource.getNearbyEventsWithDistance(
        latitude: 45,
        longitude: 9,
        radiusMeters: 25000,
      ),
      isEmpty,
    );
  });

  test(
    'Offline results omit expired events and reject malformed cache',
    () async {
      SharedPreferences.setMockInitialValues({});
      await CacheService.initialize();
      final client = SupabaseClient(
        'https://test.supabase.co',
        'test-key',
        httpClient: MockClient(
          (request) async => http.Response('offline', 503, request: request),
        ),
      );
      addTearDown(client.dispose);
      final datasource = SupabaseEventsDatasource(_Datasource(client));
      Future<void> saveCache(List<dynamic> events) =>
          CacheService.saveObject('${CacheService.keyEvents}_nearby', {
            'latitude': 45,
            'longitude': 9,
            'radius_meters': 25000,
            'events': events,
          });
      Map<String, dynamic> cachedEvent(String id, DateTime date) => {
        'id': id,
        'external_id': id,
        'source': 'test',
        'name': id,
        'event_date': date.toUtc().toIso8601String(),
      };
      await saveCache([
        cachedEvent('past', DateTime.now().subtract(const Duration(days: 2))),
        cachedEvent('future', DateTime.now().add(const Duration(days: 2))),
      ]);
      expect(
        (await datasource.getNearbyEventsWithDistance(
          latitude: 45,
          longitude: 9,
          radiusMeters: 25000,
        )).map((event) => event.id),
        ['future'],
      );
      await saveCache(['malformed']);
      await expectLater(
        datasource.getNearbyEventsWithDistance(
          latitude: 45,
          longitude: 9,
          radiusMeters: 25000,
        ),
        throwsA(isA<ServerException>()),
      );
    },
  );
}
