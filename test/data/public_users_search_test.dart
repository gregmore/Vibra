import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;
import 'package:vibra/core/errors/exceptions.dart';
import 'package:vibra/data/datasources/supabase_datasource.dart';
import 'package:vibra/data/datasources/supabase_social_datasource.dart';

class _Source extends SupabaseDatasource {
  _Source(this.testClient);
  final SupabaseClient testClient;
  User? user;
  @override
  SupabaseClient get client => testClient;
  @override
  User? get currentUser => user;
}

User _user(String id) => User(
  id: id,
  appMetadata: {},
  userMetadata: {},
  aud: 'authenticated',
  createdAt: '2026-10-13T00:00:00Z',
);

void main() {
  test(
    'Public search sends a literal bounded RPC and ignores private fields',
    () async {
      final requests = <http.Request>[];
      final client = SupabaseClient(
        'https://example.supabase.co',
        'test-key',
        httpClient: MockClient((request) async {
          requests.add(request);
          return http.Response(
            jsonEncode([
              {
                'id': 'other',
                'username': 'public',
                'display_name': 'Public Name',
                'avatar_url': null,
                'bio': 'A public bio',
                'email': 'private@example.invalid',
                'spotify_id': 'private-music',
                'fcm_token': 'private-push',
              },
            ]),
            200,
            headers: {'content-type': 'application/json'},
            request: request,
          );
        }),
      );
      addTearDown(client.dispose);
      final source = _Source(client)..user = _user('me');
      final users = await SupabaseSocialDatasource(
        source,
      ).searchPublicUsers(query: r' _%,name\ ', limit: 100);
      expect(requests, hasLength(1));
      expect(requests.single.method, 'POST');
      expect(requests.single.url.path, '/rest/v1/rpc/discover_public_users');
      expect(jsonDecode(utf8.decode(requests.single.bodyBytes)), {
        'p_query': r'_%,name\',
        'p_limit': 30,
      });
      expect(users.single.id, 'other');
      expect(users.single.bio, 'A public bio');
      expect(users.single.email, isEmpty);
      expect(users.single.spotifyId, isNull);
      expect(users.single.fcmToken, isNull);
    },
  );

  test(
    'Public search bounds Unicode characters without splitting a surrogate',
    () async {
      late Map<String, dynamic> params;
      final client = SupabaseClient(
        'https://example.supabase.co',
        'test-key',
        httpClient: MockClient((request) async {
          params =
              jsonDecode(utf8.decode(request.bodyBytes))
                  as Map<String, dynamic>;
          return http.Response(
            '[]',
            200,
            headers: {'content-type': 'application/json'},
            request: request,
          );
        }),
      );
      addTearDown(client.dispose);
      final source = _Source(client)..user = _user('me');
      await SupabaseSocialDatasource(
        source,
      ).searchPublicUsers(query: List.filled(101, '😀').join(), limit: 0);
      final query = params['p_query'] as String;
      expect(query.runes.length, 100);
      expect(query, List.filled(100, '😀').join());
      expect(params['p_limit'], 1);
    },
  );

  test('Signed-out discovery never sends a request', () async {
    var requests = 0;
    final client = SupabaseClient(
      'https://example.supabase.co',
      'test-key',
      httpClient: MockClient((request) async {
        requests++;
        return http.Response('[]', 200);
      }),
    );
    addTearDown(client.dispose);
    await expectLater(
      SupabaseSocialDatasource(_Source(client)).searchPublicUsers(),
      throwsA(isA<AuthException>()),
    );
    expect(requests, 0);
  });

  for (final success in [true, false]) {
    test(
      'A former account cannot receive its ${success ? 'result' : 'error'} after switching',
      () async {
        final pending = Completer<http.Response>();
        final started = Completer<void>();
        final client = SupabaseClient(
          'https://example.supabase.co',
          'test-key',
          httpClient: MockClient((request) {
            started.complete();
            return pending.future;
          }),
        );
        addTearDown(client.dispose);
        final source = _Source(client)..user = _user('alice');
        final expectation = expectLater(
          SupabaseSocialDatasource(source).searchPublicUsers(),
          throwsA(isA<AuthException>()),
        );
        await started.future;
        source.user = _user('bob');
        pending.complete(
          http.Response(
            success ? '[]' : '{"message":"offline"}',
            success ? 200 : 500,
            headers: {'content-type': 'application/json'},
          ),
        );
        await expectation;
      },
    );
  }

  test(
    'Current-account server failure retains discovery error context',
    () async {
      final client = SupabaseClient(
        'https://example.supabase.co',
        'test-key',
        httpClient: MockClient(
          (request) async => http.Response(
            '{"message":"offline"}',
            500,
            headers: {'content-type': 'application/json'},
          ),
        ),
      );
      addTearDown(client.dispose);
      final source = _Source(client)..user = _user('me');
      await expectLater(
        SupabaseSocialDatasource(source).searchPublicUsers(),
        throwsA(
          isA<ServerException>().having(
            (error) => error.endpoint,
            'endpoint',
            'discover_public_users',
          ),
        ),
      );
    },
  );
}
