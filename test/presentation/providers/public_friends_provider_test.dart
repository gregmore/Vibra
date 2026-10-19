import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vibra/core/constants/app_constants.dart';
import 'package:vibra/data/datasources/supabase_datasource.dart';
import 'package:vibra/data/datasources/supabase_social_datasource.dart';
import 'package:vibra/domain/entities/friendship.dart';
import 'package:vibra/domain/repositories/social_repository.dart';
import 'package:vibra/domain/usecases/social_usecases.dart';
import 'package:vibra/presentation/providers/app_state_providers.dart';
import 'package:vibra/presentation/providers/core_providers.dart';
import 'package:vibra/presentation/providers/public_friends_provider.dart';
import 'package:vibra/presentation/providers/usecase_providers.dart';

class _Repository extends Mock implements SocialRepository {}

class _Source extends SupabaseDatasource {
  User? user;
  final auth = StreamController<AuthState>.broadcast(sync: true);
  @override
  User? get currentUser => user;
  @override
  Stream<AuthState> get authStateChanges => auth.stream;
}

class _Social extends SupabaseSocialDatasource {
  _Social(super.source);
  late Future<List<Map<String, dynamic>>> Function(List<String>) profiles;
  String? selectedColumns;
  int profileCalls = 0;
  @override
  Future<List<Map<String, dynamic>>> getPublicUsersByIds(
    List<String> ids, {
    String columns = '*',
  }) {
    selectedColumns = columns;
    profileCalls++;
    return profiles(ids);
  }
}

class _Requests extends StateNotifier<List<Friendship>>
    implements PendingFriendshipsController {
  _Requests() : super([]);
  void replace(List<Friendship> requests) => state = requests;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

User _user(String id) => User(
  id: id,
  appMetadata: {},
  userMetadata: {},
  aud: 'authenticated',
  createdAt: '2026-10-14T00:00:00Z',
);
Session _session(String id) =>
    Session(accessToken: 'test', tokenType: 'bearer', user: _user(id));
const _friendship = Friendship(
  id: 'friendship',
  requesterId: 'me',
  receiverId: 'friend',
  status: 'accepted',
);
Map<String, dynamic> _profile(String id) => {
  'id': id,
  'username': id,
  'display_name': '$id display',
  'email': 'private@example.invalid',
  'spotify_id': 'private-music',
};

void main() {
  late _Source source;
  late _Social social;
  late _Repository repository;
  late _Requests requests;
  late ProviderContainer container;
  setUp(() {
    source = _Source()..user = _user('me');
    social = _Social(source);
    repository = _Repository();
    requests = _Requests();
    container = ProviderContainer(
      overrides: [
        supabaseDatasourceProvider.overrideWithValue(source),
        supabaseSocialDatasourceProvider.overrideWithValue(social),
        pendingFriendshipsProvider.overrideWith((ref) => requests),
        listFriendshipsUseCaseProvider.overrideWithValue(
          ListFriendshipsUseCase(repository),
        ),
        matchedUsersProvider.overrideWith(
          (ref) => throw StateError('Spotify matching must not be read'),
        ),
      ],
    );
  });
  tearDown(() async {
    container.dispose();
    await source.auth.close();
  });

  test(
    'Public launch exposes accepted friends independently of matching and excludes pending/foreign edges',
    () async {
      expect(AppConstants.spotifyEnabled, isFalse);
      requests.replace(const [
        Friendship(
          id: 'pending',
          requesterId: 'pending',
          receiverId: 'me',
          status: 'pending',
        ),
      ]);
      when(() => repository.listMyFriendships(status: 'accepted')).thenAnswer(
        (_) async => [
          _friendship,
          const Friendship(
            id: 'foreign',
            requesterId: 'unrelated',
            receiverId: 'outsider',
            status: 'accepted',
          ),
        ],
      );
      social.profiles = (ids) async {
        expect(ids.toSet(), {'friend', 'pending'});
        return [_profile('friend'), _profile('pending'), _profile('outsider')];
      };
      container.listen(friendsProvider, (_, _) {});
      final friends = await container.read(publicFriendsProvider.future);
      await container.pump();
      expect(friends.map((f) => f.user.id), ['friend']);
      expect(
        container.read(friendsProvider).single.user.displayName,
        'friend display',
      );
      expect(friends.single.isFriend, isTrue);
      expect(friends.single.user.email, isEmpty);
      expect(friends.single.user.spotifyId, isNull);
      expect(social.selectedColumns, 'id,username,display_name,avatar_url,bio');
      final connections = await container.read(
        publicConnectionProfilesProvider.future,
      );
      expect(
        connections.singleWhere((f) => f.user.id == 'pending').isFriend,
        isFalse,
      );
    },
  );

  test(
    'Accepting a pending request refreshes the public friends list',
    () async {
      var accepted = <Friendship>[];
      when(
        () => repository.listMyFriendships(status: 'accepted'),
      ).thenAnswer((_) async => accepted);
      requests.replace(const [
        Friendship(
          id: 'pending',
          requesterId: 'friend',
          receiverId: 'me',
          status: 'pending',
        ),
      ]);
      social.profiles = (ids) async => ids.map(_profile).toList();
      container.listen(publicFriendsProvider, (_, _) {});
      expect(await container.read(publicFriendsProvider.future), isEmpty);
      accepted = [_friendship];
      requests.replace([]);
      await container.pump();
      expect(
        (await container.read(publicFriendsProvider.future)).single.user.id,
        'friend',
      );
    },
  );

  test('Large public friend lists use bounded profile requests', () async {
    final friendships = List.generate(
      105,
      (index) => Friendship(
        id: 'request-$index',
        requesterId: 'me',
        receiverId: 'friend-$index',
        status: 'accepted',
      ),
    );
    when(
      () => repository.listMyFriendships(status: 'accepted'),
    ).thenAnswer((_) async => friendships);
    social.profiles = (ids) async {
      expect(ids.length, lessThanOrEqualTo(50));
      return ids.map(_profile).toList();
    };
    container.listen(publicFriendsProvider, (_, _) {});
    expect(await container.read(publicFriendsProvider.future), hasLength(105));
    expect(social.profileCalls, 3);
  });

  test(
    'A late private profile fetch cannot restore friends after A to B to A',
    () async {
      when(
        () => repository.listMyFriendships(status: 'accepted'),
      ).thenAnswer((_) async => [_friendship]);
      final stale = Completer<List<Map<String, dynamic>>>();
      social.profiles = (_) =>
          social.profileCalls == 1 ? stale.future : Future.value([]);
      final observed = <List<MatchedUserPreview>>[];
      container.listen(friendsProvider, (_, next) => observed.add(next));
      await container.pump();
      source.user = _user('other-account');
      source.auth.add(
        AuthState(AuthChangeEvent.signedIn, _session('other-account')),
      );
      source.user = _user('me');
      source.auth.add(AuthState(AuthChangeEvent.signedIn, _session('me')));
      await container.pump();
      stale.complete([_profile('friend')]);
      await container.pump();
      expect(observed.expand((value) => value), isEmpty);
      expect(container.read(friendsProvider), isEmpty);
    },
  );

  test('Signing out immediately hides the prior account friends', () async {
    when(
      () => repository.listMyFriendships(status: 'accepted'),
    ).thenAnswer((_) async => [_friendship]);
    social.profiles = (ids) async => ids.map(_profile).toList();
    container.listen(friendsProvider, (_, _) {});
    await container.read(publicFriendsProvider.future);
    await container.pump();
    expect(container.read(friendsProvider), hasLength(1));
    source.user = null;
    source.auth.add(const AuthState(AuthChangeEvent.signedOut, null));
    await container.pump();
    expect(container.read(friendsProvider), isEmpty);
  });
}
