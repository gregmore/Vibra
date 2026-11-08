import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vibra/core/services/support_service.dart';
import 'package:vibra/core/utils/logger.dart';

const _alice = 'a1400000-0000-0000-0000-000000000001';
const _bob = 'a1400000-0000-0000-0000-000000000002';
final _png = Uint8List.fromList([137, 80, 78, 71, 13, 10, 26, 10]);

class _Support extends SupportService {
  _Support(super.client);
  Future<Map<String, dynamic>> Function() loadDiagnostics = () async => {
    'app_version': '1.0.0+2',
    'recent_logs': <Object>[],
  };

  @override
  Future<Map<String, dynamic>> diagnostics() => loadDiagnostics();
}

Future<void> _signIn(SupabaseClient client, String userId) async {
  await client.auth.setInitialSession(
    jsonEncode({
      'access_token': 'test-token-$userId',
      'token_type': 'bearer',
      'refresh_token': 'unused-refresh',
      'user': {
        'id': userId,
        'app_metadata': {},
        'user_metadata': {},
        'aud': 'authenticated',
        'created_at': '2026-10-14T00:00:00Z',
      },
    }),
  );
}

Matcher _failure(SupportFailure failure) => isA<SupportSubmissionException>()
    .having((error) => error.failure, 'failure', failure);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  tearDown(VibraLogger.clear);

  test(
    'Oversized Unicode diagnostic logs cannot violate the backend 32 KiB limit',
    () {
      final longMessage = List.filled(5000, '😀').join();
      final raw = {
        'app_version': '1.0.0+2',
        'recent_logs': List.generate(
          30,
          (index) => {
            'timestamp': '$index',
            'level': 'error',
            'message': '$longMessage token=secret-$index',
          },
        ),
      };
      expect(utf8.encode(jsonEncode(raw)).length, greaterThan(32768));
      final bounded = SupportService.boundedDiagnostics(raw);
      expect(
        utf8.encode(jsonEncode(bounded)).length,
        lessThanOrEqualTo(24 * 1024),
      );
      final logs = bounded['recent_logs'] as List;
      expect(logs, isNotEmpty);
      expect((logs.last as Map)['timestamp'], '29');
      expect(jsonEncode(bounded), isNot(contains('secret-')));
    },
  );

  test(
    'Support sends an INSERT-only report even when native diagnostics fail',
    () async {
      final requests = <http.Request>[];
      final client = SupabaseClient(
        'https://example.supabase.co',
        'test-key',
        httpClient: MockClient((request) async {
          requests.add(request);
          return http.Response('', 201, request: request);
        }),
      );
      addTearDown(client.dispose);
      await _signIn(client, _alice);
      final service = _Support(client)
        ..loadDiagnostics = () async =>
            throw MissingPluginException('metadata unavailable');
      await service.submit(description: '  The map does not open  ');
      expect(requests, hasLength(1));
      final request = requests.single;
      expect(request.method, 'POST');
      expect(request.url.path, '/rest/v1/support_reports');
      expect(request.url.queryParameters.containsKey('select'), isFalse);
      expect(
        request.headers['prefer'],
        isNot(contains('return=representation')),
      );
      expect(request.headers['authorization'], 'Bearer test-token-$_alice');
      final payload = jsonDecode(request.body) as Map;
      expect(payload['user_id'], _alice);
      expect(payload['description'], 'The map does not open');
      expect(payload['diagnostics'], isA<Map>());
    },
  );

  test('Plugin failure is optional when collecting real diagnostics', () async {
    final client = SupabaseClient('https://example.supabase.co', 'test-key');
    addTearDown(client.dispose);
    final data = await SupportService(client).diagnostics();
    expect(data['platform'], isA<String>());
    expect(data['app_version'], 'unavailable');
  });

  test(
    'Database character limits apply to Unicode scalars, not UTF-16 units',
    () {
      expect(
        () => SupportService.validateDescription('😀😀😀😀'),
        throwsA(_failure(SupportFailure.descriptionTooShort)),
      );
      expect(
        () =>
            SupportService.validateDescription(List.filled(4000, '😀').join()),
        returnsNormally,
      );
      expect(
        () =>
            SupportService.validateDescription(List.filled(4001, '😀').join()),
        throwsA(_failure(SupportFailure.descriptionTooLong)),
      );
    },
  );

  test(
    'Invalid description or screenshot never consumes network quota',
    () async {
      var requests = 0;
      final client = SupabaseClient(
        'https://example.supabase.co',
        'test-key',
        httpClient: MockClient((request) async {
          requests++;
          return http.Response('', 201, request: request);
        }),
      );
      addTearDown(client.dispose);
      await _signIn(client, _alice);
      final service = _Support(client);
      await expectLater(
        service.submit(description: 'short'),
        throwsA(_failure(SupportFailure.descriptionTooShort)),
      );
      await expectLater(
        service.submit(
          description: 'The map does not open',
          screenshotBytes: Uint8List(SupportService.maxScreenshotBytes + 1),
        ),
        throwsA(_failure(SupportFailure.screenshotTooLarge)),
      );
      await expectLater(
        service.submit(
          description: 'The map does not open',
          screenshotBytes: Uint8List.fromList([1, 2, 3]),
        ),
        throwsA(_failure(SupportFailure.screenshotUnsupported)),
      );
      expect(requests, 0);
    },
  );

  test(
    'Signed-out support submission is rejected before any request',
    () async {
      var requests = 0;
      final client = SupabaseClient(
        'https://example.supabase.co',
        'test-key',
        httpClient: MockClient((request) async {
          requests++;
          return http.Response('', 201, request: request);
        }),
      );
      addTearDown(client.dispose);
      await expectLater(
        _Support(client).submit(description: 'The map does not open'),
        throwsA(_failure(SupportFailure.authentication)),
      );
      expect(requests, 0);
    },
  );

  for (final (code, status, expected) in [
    ('PT429', 429, SupportFailure.rateLimited),
    ('PT401', 401, SupportFailure.authentication),
    ('PGRST301', 401, SupportFailure.authentication),
    ('23514', 400, SupportFailure.unavailable),
  ]) {
    test('Support retains the actionable category for backend $code', () async {
      final client = SupabaseClient(
        'https://example.supabase.co',
        'test-key',
        httpClient: MockClient(
          (request) async => http.Response(
            jsonEncode({'code': code, 'message': 'denied'}),
            status,
            headers: {'content-type': 'application/json'},
            request: request,
          ),
        ),
      );
      addTearDown(client.dispose);
      await _signIn(client, _alice);
      await expectLater(
        _Support(client).submit(description: 'The map does not open'),
        throwsA(_failure(expected)),
      );
    });
  }

  test(
    'A retry reuses the validated private screenshot rather than uploading twice',
    () async {
      var uploads = 0;
      var submissions = 0;
      final client = SupabaseClient(
        'https://example.supabase.co',
        'test-key',
        httpClient: MockClient((request) async {
          if (request.url.path == '/functions/v1/upload-image') {
            uploads++;
            expect(
              request.url.queryParameters['bucket'],
              'support-attachments',
            );
            expect(
              request.headers['authorization'],
              'Bearer test-token-$_alice',
            );
            return http.Response(
              '{"path":"$_alice/screenshot.png"}',
              200,
              headers: {'content-type': 'application/json'},
              request: request,
            );
          }
          submissions++;
          expect(
            jsonDecode(request.body)['screenshot_path'],
            '$_alice/screenshot.png',
          );
          return submissions == 1
              ? http.Response(
                  '{"code":"PT429","message":"Rate limit"}',
                  429,
                  headers: {'content-type': 'application/json'},
                  request: request,
                )
              : http.Response('', 201, request: request);
        }),
      );
      addTearDown(client.dispose);
      await _signIn(client, _alice);
      final service = _Support(client);
      await expectLater(
        service.submit(
          description: 'The map does not open',
          screenshotBytes: _png,
        ),
        throwsA(_failure(SupportFailure.rateLimited)),
      );
      await service.submit(
        description: 'The map does not open',
        screenshotBytes: _png,
      );
      expect(uploads, 1);
      expect(submissions, 2);
    },
  );

  test(
    'An account switch while diagnostics load prevents both upload and INSERT',
    () async {
      var requests = 0;
      final pending = Completer<Map<String, dynamic>>();
      final client = SupabaseClient(
        'https://example.supabase.co',
        'test-key',
        httpClient: MockClient((request) async {
          requests++;
          return http.Response('', 201, request: request);
        }),
      );
      addTearDown(client.dispose);
      await _signIn(client, _alice);
      final service = _Support(client)..loadDiagnostics = () => pending.future;
      final expected = expectLater(
        service.submit(
          description: 'The map does not open',
          screenshotBytes: _png,
        ),
        throwsA(_failure(SupportFailure.authentication)),
      );
      await _signIn(client, _bob);
      pending.complete({});
      await expected;
      expect(requests, 0);
    },
  );

  test('An A to B to A account change cannot resume a former report', () async {
    var requests = 0;
    final pending = Completer<Map<String, dynamic>>();
    final client = SupabaseClient(
      'https://example.supabase.co',
      'test-key',
      httpClient: MockClient((request) async {
        requests++;
        return http.Response('', 201, request: request);
      }),
    );
    addTearDown(client.dispose);
    await _signIn(client, _alice);
    final service = _Support(client)..loadDiagnostics = () => pending.future;
    final expected = expectLater(
      service.submit(description: 'The map does not open'),
      throwsA(_failure(SupportFailure.authentication)),
    );
    await _signIn(client, _bob);
    await _signIn(client, _alice);
    pending.complete({});
    await expected;
    expect(requests, 0);
  });

  test(
    'Switching accounts during a screenshot upload prevents report association',
    () async {
      var submissions = 0;
      final started = Completer<void>();
      final pending = Completer<http.Response>();
      final client = SupabaseClient(
        'https://example.supabase.co',
        'test-key',
        httpClient: MockClient((request) {
          if (request.url.path == '/functions/v1/upload-image') {
            started.complete();
            return pending.future;
          }
          submissions++;
          return Future.value(http.Response('', 201, request: request));
        }),
      );
      addTearDown(client.dispose);
      await _signIn(client, _alice);
      final service = _Support(client);
      final expected = expectLater(
        service.submit(
          description: 'The map does not open',
          screenshotBytes: _png,
        ),
        throwsA(_failure(SupportFailure.authentication)),
      );
      await started.future;
      await _signIn(client, _bob);
      pending.complete(
        http.Response(
          '{"path":"$_alice/screenshot.png"}',
          200,
          headers: {'content-type': 'application/json'},
        ),
      );
      await expected;
      expect(submissions, 0);
    },
  );
}
