import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;
import 'package:vibra/core/errors/exceptions.dart';
import 'package:vibra/data/datasources/supabase_datasource.dart';
import 'package:vibra/data/datasources/supabase_social_datasource.dart';
import 'package:vibra/domain/entities/direct_message_permission.dart';

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
  createdAt: '2026-10-14T00:00:00Z',
);
http.Response _json(http.Request request, Object? value, [int status = 200]) =>
    http.Response(
      jsonEncode(value),
      status,
      headers: {'content-type': 'application/json'},
      request: request,
    );

void main() {
  late SupabaseClient client;
  late _Source source;
  late SupabaseSocialDatasource social;
  final requests = <http.Request>[];
  late Future<http.Response> Function(http.Request) reply;
  setUp(() {
    requests.clear();
    client = SupabaseClient(
      'https://example.supabase.co',
      'test-key',
      httpClient: MockClient((request) {
        requests.add(request);
        return reply(request);
      }),
    );
    source = _Source(client)..user = _user('me');
    social = SupabaseSocialDatasource(source);
  });
  tearDown(() async => client.dispose());

  test(
    'Permission is caller-scoped and unknown server values fail closed',
    () async {
      reply = (request) async => _json(request, 'friendship_required');
      expect(
        await social.getMessagePermission(receiverId: 'other'),
        DirectMessagePermission.friendshipRequired,
      );
      expect(requests.single.url.path, '/rest/v1/rpc/message_send_permission');
      expect(jsonDecode(requests.single.body), {'p_receiver_id': 'other'});
      reply = (request) async => _json(request, 'future-unrecognized-rule');
      expect(
        await social.getMessagePermission(receiverId: 'other'),
        DirectMessagePermission.unavailable,
      );
    },
  );

  test('Self and unauthenticated checks do not contact the backend', () async {
    expect(
      await social.getMessagePermission(receiverId: 'me'),
      DirectMessagePermission.unavailable,
    );
    source.user = null;
    await expectLater(
      social.getMessagePermission(receiverId: 'other'),
      throwsA(isA<AuthException>()),
    );
    expect(requests, isEmpty);
  });

  test(
    'An account switch cannot deliver a permission to the next account',
    () async {
      final response = Completer<http.Response>();
      reply = (_) => response.future;
      final pending = social.getMessagePermission(receiverId: 'other');
      await Future<void>.delayed(Duration.zero);
      source.user = _user('next');
      response.complete(_json(requests.single, 'allowed_friend'));
      await expectLater(pending, throwsA(isA<AuthException>()));
    },
  );

  test('RLS rejection retrieves an actionable friendship reason', () async {
    reply = (request) async => request.url.path.contains('/rpc/')
        ? _json(request, 'friendship_required')
        : _json(request, {
            'code': '42501',
            'message': 'row-level security',
          }, 403);
    await expectLater(
      social.sendMessage(receiverId: 'other', content: 'Hello'),
      throwsA(
        isA<DirectMessageSendException>().having(
          (e) => e.permission,
          'permission',
          DirectMessagePermission.friendshipRequired,
        ),
      ),
    );
    expect(requests, hasLength(2));
    expect(jsonDecode(requests.first.body), {
      'sender_id': 'me',
      'receiver_id': 'other',
      'content': 'Hello',
      'message_type': 'text',
    });
  });

  test(
    'A first-contact trigger rejection explains waiting for a reply',
    () async {
      reply = (request) async => request.url.path.contains('/rpc/')
          ? _json(request, 'awaiting_reply')
          : _json(request, {
              'code': 'P0001',
              'message': 'First contact limit',
            }, 400);
      await expectLater(
        social.sendMessage(receiverId: 'other', content: 'Fourth'),
        throwsA(
          isA<DirectMessageSendException>().having(
            (e) => e.permission,
            'permission',
            DirectMessagePermission.awaitingReply,
          ),
        ),
      );
    },
  );

  test(
    'The per-minute rate limit is preserved without another write',
    () async {
      reply = (request) async => _json(request, {
        'code': 'PT429',
        'message': 'Rate limit exceeded',
      }, 429);
      await expectLater(
        social.sendMessage(receiverId: 'other', content: 'Hello'),
        throwsA(
          isA<DirectMessageSendException>().having(
            (e) => e.permission,
            'permission',
            DirectMessagePermission.rateLimited,
          ),
        ),
      );
      expect(requests, hasLength(1));
    },
  );

  test(
    'A revoked session maps to authentication without a permission query',
    () async {
      reply = (request) async =>
          _json(request, {'code': 'PT401', 'message': 'Session revoked'}, 401);
      await expectLater(
        social.sendMessage(receiverId: 'other', content: 'Hello'),
        throwsA(isA<AuthException>()),
      );
      expect(requests, hasLength(1));
    },
  );

  test(
    'A successful send trims content and remains bound to the account',
    () async {
      reply = (request) async => _json(request, {
        'id': 'message',
        'sender_id': 'me',
        'receiver_id': 'other',
        'content': 'Hello',
        'created_at': '2026-10-14T10:00:00Z',
      });
      final message = await social.sendMessage(
        receiverId: 'other',
        content: ' Hello ',
      );
      expect(message.senderId, 'me');
      expect(jsonDecode(requests.single.body)['content'], 'Hello');
      expect(requests, hasLength(1));
    },
  );
}
