import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vibra/data/datasources/supabase_datasource.dart';
import 'package:vibra/presentation/providers/auth_provider.dart';
import 'package:vibra/presentation/providers/core_providers.dart';

const _alice = 'a1800000-0000-0000-0000-000000000001';
const _bob = 'a1800000-0000-0000-0000-000000000002';

class _Ref extends Mock implements Ref {}

class _Datasource extends Mock implements SupabaseDatasource {}

class _Auth extends GeneralAuthNotifier {
  _Auth(super.ref);
  int cleanups = 0;
  Future<void> Function()? cleanup;

  @override
  Future<void> clearLocalState() async {
    cleanups++;
    await cleanup?.call();
  }
}

Future<void> _signIn(SupabaseClient client, String userId) async {
  final payload = base64Url
      .encode(
        utf8.encode(
          jsonEncode({
            'sub': userId,
            'exp':
                DateTime.now()
                    .add(const Duration(hours: 1))
                    .millisecondsSinceEpoch ~/
                1000,
          }),
        ),
      )
      .replaceAll('=', '');
  await client.auth.setInitialSession(
    jsonEncode({
      'access_token': 'e30.$payload.signature',
      'refresh_token': 'synthetic-refresh',
      'token_type': 'bearer',
      'expires_in': 3600,
      'user': {
        'id': userId,
        'aud': 'authenticated',
        'app_metadata': {},
        'user_metadata': {},
        'created_at': '2026-10-18T00:00:00Z',
      },
    }),
  );
}

_Auth _notifier(SupabaseClient client) {
  final ref = _Ref();
  final datasource = _Datasource();
  when(() => datasource.client).thenReturn(client);
  when(() => datasource.currentUser).thenAnswer((_) => client.auth.currentUser);
  when(() => ref.read(supabaseDatasourceProvider)).thenReturn(datasource);
  final notifier = _Auth(ref);
  addTearDown(notifier.dispose);
  return notifier;
}

SupabaseClient _client(Future<http.Response> Function(http.Request) handle) {
  final client = SupabaseClient(
    'https://example.supabase.co',
    'synthetic-anon',
    authOptions: const AuthClientOptions(autoRefreshToken: false),
    httpClient: MockClient(handle),
  );
  addTearDown(client.dispose);
  return client;
}

http.Response _json(String body, int status) =>
    http.Response(body, status, headers: {'content-type': 'application/json'});

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'Confirmed erasure signs out locally after the server revokes the user',
    () async {
      final paths = <String>[];
      final client = _client((request) async {
        paths.add(request.url.path);
        if (request.url.path == '/functions/v1/delete-account') {
          return _json('{"deleted":true}', 200);
        }
        expect(request.url.queryParameters['scope'], 'local');
        return _json('{"code":"user_not_found","msg":"User deleted"}', 403);
      });
      await _signIn(client, _alice);
      final notifier = _notifier(client);

      await notifier.deleteAccount();

      expect(paths, ['/functions/v1/delete-account', '/auth/v1/logout']);
      expect(notifier.cleanups, 1);
      expect(client.auth.currentSession, isNull);
      expect(notifier.state.status, GeneralAuthStatus.idle);
    },
  );

  test('A cleanup failure cannot keep an erased account signed in', () async {
    final client = _client((request) async {
      if (request.url.path == '/functions/v1/delete-account') {
        return _json('{"deleted":true}', 200);
      }
      // Even an unexpected logout response follows removal of the local session.
      return _json(
        '{"code":"unexpected_failure","msg":"Logout unavailable"}',
        400,
      );
    });
    await _signIn(client, _alice);
    final notifier = _notifier(client)
      ..cleanup = () async => throw StateError('cache unavailable');

    await notifier.deleteAccount();

    expect(notifier.cleanups, 1);
    expect(client.auth.currentSession, isNull);
    expect(notifier.state.status, GeneralAuthStatus.idle);
  });

  for (final response in [
    _json('{"deleted":false}', 200),
    _json('{}', 200),
    _json('true', 200),
    _json('{"deleted":true}', 202),
  ]) {
    test(
      'Unconfirmed ${response.statusCode}/${response.body} preserves the session',
      () async {
        final paths = <String>[];
        final client = _client((request) async {
          paths.add(request.url.path);
          return response;
        });
        await _signIn(client, _alice);
        final notifier = _notifier(client);

        await expectLater(
          notifier.deleteAccount(),
          throwsA(isA<AuthException>()),
        );

        expect(paths, ['/functions/v1/delete-account']);
        expect(notifier.cleanups, 0);
        expect(client.auth.currentUser?.id, _alice);
        expect(notifier.state.status, GeneralAuthStatus.error);
      },
    );
  }

  test(
    'Server erasure failure leaves the account available for retry',
    () async {
      final client = _client(
        (_) async => _json('{"error":"account_erasure_failed"}', 500),
      );
      await _signIn(client, _alice);
      final notifier = _notifier(client);

      await expectLater(
        notifier.deleteAccount(),
        throwsA(isA<FunctionException>()),
      );

      expect(notifier.cleanups, 0);
      expect(client.auth.currentUser?.id, _alice);
      expect(notifier.state.status, GeneralAuthStatus.error);
    },
  );

  test(
    'A late erasure acknowledgement cannot sign out another account',
    () async {
      final started = Completer<void>();
      final response = Completer<http.Response>();
      final paths = <String>[];
      final client = _client((request) {
        paths.add(request.url.path);
        started.complete();
        return response.future;
      });
      await _signIn(client, _alice);
      final notifier = _notifier(client);
      final deletion = notifier.deleteAccount();
      await started.future;
      await _signIn(client, _bob);
      response.complete(_json('{"deleted":true}', 200));

      await deletion;

      expect(paths, ['/functions/v1/delete-account']);
      expect(notifier.cleanups, 0);
      expect(client.auth.currentUser?.id, _bob);
      expect(notifier.state.status, GeneralAuthStatus.authenticated);
      expect(notifier.state.user?.id, _bob);
    },
  );

  test('A signed-out erasure attempt makes no network request', () async {
    var requests = 0;
    final client = _client((_) async {
      requests++;
      return _json('{"deleted":true}', 200);
    });
    final notifier = _notifier(client);

    await expectLater(notifier.deleteAccount(), throwsA(isA<AuthException>()));

    expect(requests, 0);
    expect(notifier.cleanups, 0);
    expect(notifier.state.status, GeneralAuthStatus.error);
  });
}
