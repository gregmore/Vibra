import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show User;
import 'package:vibra/core/constants/db_tables.dart';
import 'package:vibra/core/errors/exceptions.dart';
import 'package:vibra/core/services/cache_service.dart';
import 'package:vibra/data/datasources/supabase_datasource.dart';
import 'package:vibra/data/datasources/supabase_profile_datasource.dart';
import 'package:vibra/data/models/user_model.dart';

class _Source extends SupabaseDatasource {
  User? user;
  late Future<List<Map<String, dynamic>>> Function() load;
  late Future<Map<String, dynamic>> Function(Map<String, dynamic>) save;

  @override
  User? get currentUser => user;

  @override
  Future<List<Map<String, dynamic>>> select(
    String table, {
    String columns = '*',
    Map<String, dynamic>? filters,
    String? orderBy,
    bool ascending = true,
    int? limit,
    int? offset,
  }) {
    expect(table, DbTables.users);
    expect(filters, {'id': user!.id});
    expect(limit, 1);
    return load();
  }

  @override
  Future<Map<String, dynamic>> upsert(
    String table,
    Map<String, dynamic> data, {
    String? onConflict,
  }) {
    expect(table, DbTables.users);
    expect(onConflict, 'id');
    expect(data.containsKey('spotify_id'), isFalse);
    expect(data.containsKey('spotify_access_token'), isFalse);
    expect(data.containsKey('spotify_refresh_token'), isFalse);
    return save(data);
  }
}

User _user(String id) => User(
  id: id,
  appMetadata: {},
  userMetadata: {},
  aud: 'authenticated',
  createdAt: '2026-10-13T00:00:00Z',
);

const _oldProfile = UserModel(
  id: 'alice',
  email: 'alice@example.invalid',
  username: 'alice',
  avatarUrl: 'https://example.invalid/old.jpg',
);
const _newProfile = UserModel(
  id: 'alice',
  email: 'alice@example.invalid',
  username: 'alice',
  avatarUrl: 'https://example.invalid/confirmed.jpg',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await CacheService.initialize();
    await CacheService.clearAll();
  });
  tearDown(CacheService.clearAll);

  test(
    'A stale fetch cannot replace the confirmed avatar or its offline fallback',
    () async {
      final pending = Completer<List<Map<String, dynamic>>>();
      final source = _Source()
        ..user = _user('alice')
        ..load = () => pending.future;
      final datasource = SupabaseProfileDatasource(source);
      final staleFetch = datasource.getMyUser();

      // This is the confirmed response accepted and cached by the controller
      // while an older request is still waiting for the network.
      await CacheService.saveObject(
        'CACHE_USER_PROFILE_alice',
        _newProfile.toJson(),
      );
      pending.complete([_oldProfile.toJson()]);
      expect((await staleFetch).avatarUrl, _oldProfile.avatarUrl);
      expect(
        CacheService.getObject('CACHE_USER_PROFILE_alice')?['avatar_url'],
        _newProfile.avatarUrl,
      );

      source.load = () async =>
          throw const ServerException(message: 'Network unavailable');
      expect((await datasource.getMyUser()).avatarUrl, _newProfile.avatarUrl);
    },
  );

  test(
    'A delayed bootstrap upsert does not overwrite confirmed cache',
    () async {
      final pending = Completer<Map<String, dynamic>>();
      final source = _Source()
        ..user = _user('alice')
        ..save = (data) => pending.future;
      final datasource = SupabaseProfileDatasource(source);
      final bootstrap = datasource.upsertMyUser(_oldProfile);
      await CacheService.saveObject(
        'CACHE_USER_PROFILE_alice',
        _newProfile.toJson(),
      );
      pending.complete(_oldProfile.toJson());
      expect((await bootstrap).avatarUrl, _oldProfile.avatarUrl);
      expect(
        CacheService.getObject('CACHE_USER_PROFILE_alice')?['avatar_url'],
        _newProfile.avatarUrl,
      );
    },
  );

  test(
    'A fetched row from a former account is rejected after switching',
    () async {
      final pending = Completer<List<Map<String, dynamic>>>();
      final source = _Source()
        ..user = _user('alice')
        ..load = () => pending.future;
      final datasource = SupabaseProfileDatasource(source);
      await CacheService.saveObject(
        'CACHE_USER_PROFILE_alice',
        _oldProfile.toJson(),
      );
      final expectation = expectLater(
        datasource.getMyUser(),
        throwsA(isA<AuthException>()),
      );
      source.user = _user('bob');
      pending.complete([_oldProfile.toJson()]);
      await expectation;
      expect(CacheService.getObject('CACHE_USER_PROFILE_bob'), isNull);
    },
  );

  test(
    'Failed former-account fetch cannot return its cached private row',
    () async {
      final pending = Completer<List<Map<String, dynamic>>>();
      final source = _Source()
        ..user = _user('alice')
        ..load = () => pending.future;
      final datasource = SupabaseProfileDatasource(source);
      await CacheService.saveObject(
        'CACHE_USER_PROFILE_alice',
        _oldProfile.toJson(),
      );
      final expectation = expectLater(
        datasource.getMyUser(),
        throwsA(isA<AuthException>()),
      );
      source.user = _user('bob');
      pending.completeError(
        const ServerException(message: 'Network unavailable'),
      );
      await expectation;
      expect(CacheService.getObject('CACHE_USER_PROFILE_bob'), isNull);
    },
  );

  test(
    'Former-account upsert cannot populate a new session after logout',
    () async {
      final pending = Completer<Map<String, dynamic>>();
      final source = _Source()
        ..user = _user('alice')
        ..save = (data) => pending.future;
      final datasource = SupabaseProfileDatasource(source);
      final expectation = expectLater(
        datasource.upsertMyUser(_oldProfile),
        throwsA(isA<AuthException>()),
      );
      source.user = null;
      pending.complete(_oldProfile.toJson());
      await expectation;
      expect(CacheService.getObject('CACHE_USER_PROFILE_alice'), isNull);
    },
  );
}
