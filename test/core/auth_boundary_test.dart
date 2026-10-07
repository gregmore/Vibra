import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide Headers;
import 'package:vibra/core/services/secure_storage_service.dart';
import 'package:vibra/core/services/spotify_token_storage.dart';
import 'package:vibra/data/datasources/spotify_auth_datasource.dart';
import 'package:vibra/data/datasources/supabase_datasource.dart';
import 'package:vibra/domain/entities/spotify_session.dart';
import 'package:vibra/domain/repositories/spotify_auth_repository.dart';
import 'package:vibra/presentation/providers/auth_provider.dart';
import 'package:vibra/presentation/providers/core_providers.dart';

class FakeRef extends Mock implements Ref {}

class FakeDatasource extends Mock implements SupabaseDatasource {}

class FakeTokens extends Mock implements SpotifyTokenStorage {}

class FakeRepository extends Mock implements SpotifyAuthRepository {}

class MemorySecureStorage extends SecureStorageService {
  final values = <String, String>{};
  @override
  Future<void> write({required String key, required String value}) async {
    values[key] = value;
  }

  @override
  Future<String?> read({required String key}) async => values[key];
  @override
  Future<void> delete({required String key}) async {
    values.remove(key);
  }
}

class TestAuthNotifier extends GeneralAuthNotifier {
  TestAuthNotifier(super.ref);
  int cleanups = 0;
  @override
  Future<void> clearLocalState() async {
    cleanups++;
  }
}

class UnauthorizedAdapter implements HttpClientAdapter {
  int calls = 0;
  final authorizations = <Object?>[];
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    calls++;
    authorizations.add(options.headers['Authorization']);
    return ResponseBody.fromString(
      '{}',
      401,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'failed login B cannot leave the previous Supabase account A active',
    () async {
      final requests = <String>[];
      final client = SupabaseClient(
        'https://example.supabase.co',
        'test-anon',
        authOptions: const AuthClientOptions(autoRefreshToken: false),
        httpClient: MockClient((request) async {
          requests.add(request.url.path);
          if (request.url.path.endsWith('/logout')) {
            return http.Response('', 204);
          }
          return http.Response(
            '{"code":"invalid_credentials","msg":"Invalid credentials"}',
            400,
            headers: {'content-type': 'application/json'},
          );
        }),
      );
      final exp =
          DateTime.now().add(const Duration(hours: 1)).millisecondsSinceEpoch ~/
          1000;
      final token =
          'e30.${base64Url.encode(utf8.encode(jsonEncode({'exp': exp, 'sub': 'alice'}))).replaceAll('=', '')}.signature';
      await client.auth.setInitialSession(
        jsonEncode({
          'access_token': token,
          'refresh_token': 'old-refresh',
          'token_type': 'bearer',
          'expires_in': 3600,
          'user': {
            'id': 'alice',
            'aud': 'authenticated',
            'app_metadata': {},
            'user_metadata': {},
            'created_at': '2026-09-12T00:00:00Z',
          },
        }),
      );
      final ref = FakeRef();
      final datasource = FakeDatasource();
      final tokens = FakeTokens();
      when(() => datasource.client).thenReturn(client);
      when(
        () => datasource.currentUser,
      ).thenAnswer((_) => client.auth.currentUser);
      when(() => ref.read(supabaseDatasourceProvider)).thenReturn(datasource);
      when(() => ref.read(spotifyTokenStorageProvider)).thenReturn(tokens);
      when(() => tokens.clear()).thenAnswer((_) async {});
      final notifier = TestAuthNotifier(ref);
      await notifier.signInWithEmail('bob@example.invalid', 'wrong-password');
      expect(client.auth.currentSession, isNull);
      expect(notifier.state.status, GeneralAuthStatus.error);
      expect(requests, ['/auth/v1/logout', '/auth/v1/token']);
      expect(notifier.cleanups, 1);
      verify(() => tokens.clear()).called(1);
      notifier.dispose();
      await client.dispose();
    },
  );
  test('Spotify token namespaces isolate users and environments', () async {
    final storage = MemorySecureStorage();
    final a = SpotifyTokenStorage(storage, namespace: 'staging_A');
    final b = SpotifyTokenStorage(storage, namespace: 'staging_B');
    final prod = SpotifyTokenStorage(storage, namespace: 'production_A');
    await a.saveAccessToken('private-A');
    await b.saveAccessToken('private-B');
    expect(await prod.readAccessToken(), isNull);
    await a.clear();
    expect(await a.readAccessToken(), isNull);
    expect(await b.readAccessToken(), 'private-B');
  });
  test('OAuth callback validates exact redirect, one state, and one code', () {
    const redirect = 'com.vibra.app://callback';
    expect(
      SpotifyAuthDatasource.validateCallback(
        '$redirect?state=nonce&code=valid',
        redirect,
        'nonce',
      ),
      'valid',
    );
    for (final callback in [
      'com.vibra.app://other?state=nonce&code=valid',
      '$redirect?state=wrong&code=valid',
      '$redirect?code=valid',
      '$redirect?state=nonce&state=nonce&code=valid',
      '$redirect?state=nonce&code=first&code=second',
      '$redirect?state=nonce&code=valid#fragment',
    ]) {
      expect(
        () =>
            SpotifyAuthDatasource.validateCallback(callback, redirect, 'nonce'),
        throwsException,
      );
    }
  });
  for (final host in ['third-party.example', 'api.spotify.com']) {
    test('Spotify retry is bounded and confined to $host', () async {
      final ref = FakeRef();
      final repo = FakeRepository();
      final adapter = UnauthorizedAdapter();
      final dio = Dio()..httpClientAdapter = adapter;
      when(() => ref.read(spotifyAuthRepositoryProvider)).thenReturn(repo);
      when(() => ref.read(spotifyDioProvider)).thenReturn(dio);
      when(() => repo.refreshSession()).thenAnswer(
        (_) async => const SpotifySession(
          accessToken: 'spotify-private',
          refreshToken: 'refresh',
          expiresIn: 3600,
        ),
      );
      dio.interceptors.add(SpotifyAuthInterceptor(ref));
      await expectLater(
        dio.get('https://$host/v1/me'),
        throwsA(isA<DioException>()),
      );
      if (host == 'api.spotify.com') {
        expect(adapter.calls, 2);
        verify(() => repo.refreshSession()).called(1);
      } else {
        expect(adapter.calls, 1);
        expect(adapter.authorizations, [null]);
        verifyNever(() => repo.refreshSession());
      }
      dio.close();
    });
  }
}
