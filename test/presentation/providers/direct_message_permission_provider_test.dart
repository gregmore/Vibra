import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vibra/data/datasources/supabase_datasource.dart';
import 'package:vibra/data/datasources/supabase_social_datasource.dart';
import 'package:vibra/domain/entities/direct_message_permission.dart';
import 'package:vibra/domain/entities/friendship.dart';
import 'package:vibra/presentation/providers/app_state_providers.dart';
import 'package:vibra/presentation/providers/core_providers.dart';
import 'package:vibra/presentation/providers/direct_message_permission_provider.dart';

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
  late Future<DirectMessagePermission> Function() permission;
  int checks = 0;
  @override
  Future<DirectMessagePermission> getMessagePermission({
    required String receiverId,
  }) {
    checks++;
    return permission();
  }
}

class _Requests extends StateNotifier<List<Friendship>>
    implements PendingFriendshipsController {
  _Requests() : super([]);
  void changed() => state = [];
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

void main() {
  late _Source source;
  late _Social social;
  late _Requests requests;
  late ProviderContainer container;
  setUp(() {
    source = _Source()..user = _user('me');
    social = _Social(source);
    requests = _Requests();
    container = ProviderContainer(
      overrides: [
        supabaseDatasourceProvider.overrideWithValue(source),
        supabaseSocialDatasourceProvider.overrideWithValue(social),
        pendingFriendshipsProvider.overrideWith((ref) => requests),
      ],
    );
  });
  tearDown(() async {
    container.dispose();
    await source.auth.close();
  });

  test(
    'A friendship change rechecks and unlocks an accepted conversation',
    () async {
      var status = DirectMessagePermission.friendshipRequired;
      social.permission = () async => status;
      container.listen(directMessagePermissionProvider('other'), (_, _) {});
      expect(
        await container.read(directMessagePermissionProvider('other').future),
        status,
      );
      status = DirectMessagePermission.friends;
      requests.changed();
      await container.pump();
      expect(
        await container.read(directMessagePermissionProvider('other').future),
        DirectMessagePermission.friends,
      );
      expect(social.checks, 2);
    },
  );

  test(
    'An old request cannot authorize an account after A to B to A',
    () async {
      final stale = Completer<DirectMessagePermission>();
      social.permission = () => social.checks == 1
          ? stale.future
          : Future.value(DirectMessagePermission.unavailable);
      final values = <DirectMessagePermission>[];
      container.listen(directMessagePermissionProvider('other'), (_, next) {
        if (!next.isLoading && !next.hasError && next.valueOrNull != null) {
          values.add(next.valueOrNull!);
        }
      });
      await container.pump();
      source.user = _user('other-account');
      source.auth.add(
        AuthState(AuthChangeEvent.signedIn, _session('other-account')),
      );
      source.user = _user('me');
      source.auth.add(AuthState(AuthChangeEvent.signedIn, _session('me')));
      await container.pump();
      stale.complete(DirectMessagePermission.friends);
      await container.pump();
      expect(values, isNot(contains(DirectMessagePermission.friends)));
      expect(
        container.read(directMessagePermissionProvider('other')).valueOrNull,
        DirectMessagePermission.unavailable,
      );
    },
  );
}
