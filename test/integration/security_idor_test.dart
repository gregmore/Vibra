import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;
import 'package:vibra/core/constants/db_tables.dart';
import 'package:vibra/core/errors/exceptions.dart';
import 'package:vibra/data/datasources/supabase_datasource.dart';
import 'package:vibra/data/datasources/supabase_social_datasource.dart';
import '../helpers/test_http_overrides.dart';

class MockSupabaseDatasource extends Mock implements SupabaseDatasource {}

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockUser extends Mock implements User {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    HttpOverrides.global = TestHttpOverrides();
    dotenv.testLoad(
      mergeWith: {
        'SUPABASE_URL': 'https://fake.supabase.co',
        'SUPABASE_ANON_KEY': 'fakeAnonKey',
        'SPOTIFY_CLIENT_ID': 'fakeSpotifyClientId',
        'SPOTIFY_REDIRECT_URI': 'com.vibra.app://callback',
      },
    );
  });

  tearDownAll(() {
    HttpOverrides.global = null;
  });

  group('Security IDOR & Client-Side Identity Binding Tests', () {
    late MockSupabaseDatasource mockDatasource;
    late MockUser mockUser;
    late SupabaseSocialDatasource socialDatasource;
    const currentUserId = 'authenticated-user-uuid-1111';
    const targetUserId = 'target-user-uuid-2222';

    setUp(() {
      mockDatasource = MockSupabaseDatasource();
      mockUser = MockUser();
      when(() => mockUser.id).thenReturn(currentUserId);
      when(() => mockDatasource.currentUser).thenReturn(mockUser);
      socialDatasource = SupabaseSocialDatasource(mockDatasource);
    });

    test(
      'sendMessage binds sender_id to authenticated user id and prevents spoofing',
      () async {
        when(() => mockDatasource.insert(DbTables.messages, any())).thenAnswer((
          invocation,
        ) async {
          final payload =
              invocation.positionalArguments[1] as Map<String, dynamic>;
          expect(payload['sender_id'], equals(currentUserId));
          expect(payload['receiver_id'], equals(targetUserId));
          return {
            'id': 'msg-123',
            'sender_id': currentUserId,
            'receiver_id': targetUserId,
            'content': 'Ciao!',
            'created_at': DateTime.now().toIso8601String(),
          };
        });

        final result = await socialDatasource.sendMessage(
          receiverId: targetUserId,
          content: 'Ciao!',
        );

        expect(result.senderId, equals(currentUserId));
        expect(result.receiverId, equals(targetUserId));
        verify(
          () => mockDatasource.insert(DbTables.messages, {
            'sender_id': currentUserId,
            'receiver_id': targetUserId,
            'content': 'Ciao!',
            'message_type': 'text',
          }),
        ).called(1);
      },
    );

    test(
      'requestFriendship binds requester_id to authenticated user id',
      () async {
        when(
          () => mockDatasource.insert(DbTables.friendships, any()),
        ).thenAnswer((invocation) async {
          final payload =
              invocation.positionalArguments[1] as Map<String, dynamic>;
          expect(payload['requester_id'], equals(currentUserId));
          expect(payload['receiver_id'], equals(targetUserId));
          return {
            'id': 'friendship-123',
            'requester_id': currentUserId,
            'receiver_id': targetUserId,
            'status': 'pending',
            'created_at': DateTime.now().toIso8601String(),
          };
        });

        final result = await socialDatasource.requestFriendship(
          receiverId: targetUserId,
        );

        expect(result.requesterId, equals(currentUserId));
        expect(result.receiverId, equals(targetUserId));
      },
    );

    test('blockUser binds blocker_id to authenticated user id', () async {
      when(() => mockDatasource.insert('blocked_users', any())).thenAnswer((
        invocation,
      ) async {
        final payload =
            invocation.positionalArguments[1] as Map<String, dynamic>;
        expect(payload['blocker_id'], equals(currentUserId));
        expect(payload['blocked_id'], equals(targetUserId));
        return payload;
      });

      await socialDatasource.blockUser(blockedId: targetUserId);

      verify(
        () => mockDatasource.insert('blocked_users', {
          'blocker_id': currentUserId,
          'blocked_id': targetUserId,
        }),
      ).called(1);
    });

    test('reportUser binds reporter_id to authenticated user id', () async {
      when(() => mockDatasource.insert('reports', any())).thenAnswer((
        invocation,
      ) async {
        final payload =
            invocation.positionalArguments[1] as Map<String, dynamic>;
        expect(payload['reporter_id'], equals(currentUserId));
        expect(payload['reported_id'], equals(targetUserId));
        return payload;
      });

      await socialDatasource.reportUser(
        reportedId: targetUserId,
        reason: 'spam',
      );

      verify(
        () => mockDatasource.insert('reports', {
          'reporter_id': currentUserId,
          'reported_id': targetUserId,
          'reason': 'spam',
        }),
      ).called(1);
    });

    test(
      'Unauthenticated user throws AuthException for social actions',
      () async {
        when(() => mockDatasource.currentUser).thenReturn(null);

        expect(
          () => socialDatasource.sendMessage(
            receiverId: targetUserId,
            content: 'Hacked',
          ),
          throwsA(
            isA<AuthException>().having(
              (e) => e.message,
              'message',
              contains('Utente non autenticato'),
            ),
          ),
        );

        expect(
          () => socialDatasource.requestFriendship(receiverId: targetUserId),
          throwsA(isA<AuthException>()),
        );

        expect(
          () => socialDatasource.blockUser(blockedId: targetUserId),
          throwsA(isA<AuthException>()),
        );

        expect(
          () => socialDatasource.reportUser(
            reportedId: targetUserId,
            reason: 'spam',
          ),
          throwsA(isA<AuthException>()),
        );
      },
    );
  });
}
