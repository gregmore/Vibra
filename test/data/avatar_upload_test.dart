import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vibra/core/errors/exceptions.dart' show ServerException;
import 'package:vibra/data/datasources/supabase_datasource.dart';

class TestDatasource extends SupabaseDatasource {
  TestDatasource(this.testClient);
  final SupabaseClient testClient;

  @override
  SupabaseClient get client => testClient;
}

void main() {
  test('Avatar uses validated gateway and its server-generated path', () async {
    final client = SupabaseClient(
      'https://example.supabase.co',
      'test-key',
      httpClient: MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, '/functions/v1/upload-image');
        expect(request.url.queryParameters['bucket'], 'avatars');
        expect(request.headers['content-type'], 'application/octet-stream');
        expect(request.bodyBytes, [1, 2, 3]);
        return http.Response(
          '{"path":"user/server-generated.png"}',
          200,
          headers: {'content-type': 'application/json'},
        );
      }),
    );
    addTearDown(client.dispose);
    final url = await TestDatasource(client).uploadFile(
      'avatars',
      'user/photo.jpg',
      Uint8List.fromList([1, 2, 3]),
      contentType: 'image/jpeg',
      upsert: false,
    );
    expect(
      url,
      endsWith('/storage/v1/object/public/avatars/user/server-generated.png'),
    );
  });

  test('Gateway denial preserves the HTTP status', () async {
    final client = SupabaseClient(
      'https://example.supabase.co',
      'test-key',
      httpClient: MockClient(
        (request) async => http.Response(
          '{"statusCode":"403","error":"Unauthorized","message":"Upload denied"}',
          403,
          headers: {'content-type': 'application/json'},
        ),
      ),
    );
    addTearDown(client.dispose);
    await expectLater(
      TestDatasource(
        client,
      ).uploadFile('avatars', 'user/photo.jpg', Uint8List(1), upsert: false),
      throwsA(
        isA<ServerException>().having((e) => e.statusCode, 'status', 403),
      ),
    );
  });
  for (final (status, feedback) in [
    (415, 'JPG o PNG'),
    (413, '5 MB'),
    (401, 'Sessione scaduta'),
  ]) {
    test('Avatar upload $status gives actionable feedback', () async {
      final client = SupabaseClient(
        'https://example.supabase.co',
        'test-key',
        httpClient: MockClient(
          (request) async => http.Response(
            '{"error":"upload_denied"}',
            status,
            headers: {'content-type': 'application/json'},
            request: request,
          ),
        ),
      );
      addTearDown(client.dispose);
      await expectLater(
        TestDatasource(
          client,
        ).uploadFile('avatars', 'user/photo.jpg', Uint8List(1)),
        throwsA(
          isA<ServerException>().having(
            (error) => error.message,
            'feedback',
            contains(feedback),
          ),
        ),
      );
    });
  }
}
