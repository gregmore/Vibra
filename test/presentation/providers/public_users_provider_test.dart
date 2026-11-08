import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;
import 'package:vibra/core/errors/exceptions.dart';
import 'package:vibra/data/datasources/supabase_datasource.dart';
import 'package:vibra/data/datasources/supabase_social_datasource.dart';
import 'package:vibra/domain/entities/app_user.dart';
import 'package:vibra/presentation/providers/core_providers.dart';
import 'package:vibra/presentation/providers/public_users_provider.dart';

User _user(String id) => User(
  id: id,
  appMetadata: {},
  userMetadata: {},
  aud: 'authenticated',
  createdAt: '2026-10-13T00:00:00Z',
);
const _publicUser = AppUser(id: 'visible', email: '', username: 'visible');

class _Source extends SupabaseDatasource {
  User? user = _user('alice');
  final changes = StreamController<AuthState>.broadcast(sync: true);
  @override
  User? get currentUser => user;
  @override
  Stream<AuthState> get authStateChanges => changes.stream;
  void switchTo(String id) {
    user = _user(id);
    changes.add(
      AuthState(
        AuthChangeEvent.signedIn,
        Session(accessToken: 'test', tokenType: 'bearer', user: user!),
      ),
    );
  }
}

class _Social extends SupabaseSocialDatasource {
  _Social(super.source);
  final queries = <String>[];
  final results = <Completer<List<AppUser>>>[];
  @override
  Future<List<AppUser>> searchPublicUsers({String query = '', int limit = 30}) {
    queries.add(query);
    final pending = Completer<List<AppUser>>();
    results.add(pending);
    return pending.future;
  }
}

void main() {
  late _Source source;
  late _Social social;
  late ProviderContainer container;
  setUp(() {
    source = _Source();
    social = _Social(source);
    container = ProviderContainer(
      overrides: [
        supabaseDatasourceProvider.overrideWithValue(source),
        supabaseSocialDatasourceProvider.overrideWithValue(social),
      ],
    );
  });
  tearDown(() async {
    container.dispose();
    await source.changes.close();
  });

  test(
    'Discovery publishes only public facts without music inference',
    () async {
      final subscription = container.listen(
        publicUsersProvider(r' _%,name\ '),
        (_, _) {},
      );
      addTearDown(subscription.close);
      final future = container.read(publicUsersProvider(r' _%,name\ ').future);
      expect(social.queries, [r'_%,name\']);
      social.results.single.complete([_publicUser]);
      final users = await future;
      expect(users.single.user, same(_publicUser));
      expect(users.single.compatibility, 0);
      expect(users.single.topArtists, isEmpty);
      expect(users.single.city, isEmpty);
      expect(users.single.attendingEvents, 0);
    },
  );

  test(
    'Account change rejects a delayed result even before an auth event',
    () async {
      final subscription = container.listen(publicUsersProvider(''), (_, _) {});
      addTearDown(subscription.close);
      final expectation = expectLater(
        container.read(publicUsersProvider('').future),
        throwsA(isA<AuthException>()),
      );
      source.user = _user('bob');
      social.results.single.complete([_publicUser]);
      await expectation;
    },
  );

  test(
    'Returning to the same account cannot restore an earlier generation',
    () async {
      final subscription = container.listen(publicUsersProvider(''), (_, _) {});
      addTearDown(subscription.close);
      source.switchTo('bob');
      // invalidation is lazy: force a read for each actual account generation.
      expect(container.read(publicUsersProvider('')).isLoading, isTrue);
      expect(social.results, hasLength(2));
      source.switchTo('alice');
      expect(container.read(publicUsersProvider('')).isLoading, isTrue);
      expect(social.results, hasLength(3));
      final current = container.read(publicUsersProvider('').future);
      social.results.last.complete([_publicUser]);
      expect((await current).single.user.id, 'visible');
      social.results.first.complete([
        const AppUser(id: 'stale', email: '', username: 'stale'),
      ]);
      social.results[1].complete([]);
      await container.pump();
      expect(
        container.read(publicUsersProvider('')).requireValue.single.user.id,
        'visible',
      );
    },
  );

  test(
    'Signed-out discovery stays empty without querying the backend',
    () async {
      source.user = null;
      expect(await container.read(publicUsersProvider('').future), isEmpty);
      expect(social.queries, isEmpty);
    },
  );

  test('A signed-out family automatically searches after sign-in', () async {
    source.user = null;
    final subscription = container.listen(publicUsersProvider(''), (_, _) {});
    addTearDown(subscription.close);
    expect(await container.read(publicUsersProvider('').future), isEmpty);
    expect(social.queries, isEmpty);
    source.switchTo('alice');
    final current = container.read(publicUsersProvider('').future);
    expect(social.queries, ['']);
    social.results.single.complete([_publicUser]);
    expect((await current).single.user.id, 'visible');
  });
}
