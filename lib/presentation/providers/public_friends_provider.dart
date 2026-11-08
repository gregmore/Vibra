import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/exceptions.dart';
import '../../domain/entities/app_user.dart';
import 'app_state_providers.dart';
import 'core_providers.dart';
import 'usecase_providers.dart';

/// Accepted friendships exist independently of Spotify or musical matching.
final publicConnectionProfilesProvider =
    FutureProvider.autoDispose<List<MatchedUserPreview>>((ref) async {
      final pending = ref.watch(pendingFriendshipsProvider);
      final source = ref.watch(supabaseDatasourceProvider);
      final accountId = source.currentUser?.id;
      var active = true;
      final subscription = source.authStateChanges.listen((event) {
        if (event.session?.user.id != accountId) ref.invalidateSelf();
      });
      ref.onDispose(() {
        active = false;
        subscription.cancel();
      });
      if (accountId == null) return const [];
      void requireCurrentAccount() {
        if (!active || source.currentUser?.id != accountId) {
          throw const AuthException(message: 'La sessione è cambiata.');
        }
      }

      final friendships = await ref
          .watch(listFriendshipsUseCaseProvider)
          .call('accepted');
      requireCurrentAccount();
      final acceptedIds = friendships
          .where(
            (f) =>
                f.status == 'accepted' &&
                (f.requesterId == accountId || f.receiverId == accountId),
          )
          .map((f) => f.requesterId == accountId ? f.receiverId : f.requesterId)
          .where((id) => id != accountId && id.isNotEmpty)
          .toSet();
      final connectedIds = <String>{
        ...acceptedIds,
        ...pending
            .where(
              (f) =>
                  f.status == 'pending' &&
                  (f.requesterId == accountId || f.receiverId == accountId),
            )
            .map(
              (f) => f.requesterId == accountId ? f.receiverId : f.requesterId,
            )
            .where((id) => id != accountId && id.isNotEmpty),
      };
      if (connectedIds.isEmpty) return const [];
      final social = ref.watch(supabaseSocialDatasourceProvider);
      final ids = connectedIds.toList(growable: false);
      final rows = <Map<String, dynamic>>[];
      // A large friend/request list must not exceed gateway URL limits.
      for (var offset = 0; offset < ids.length; offset += 50) {
        requireCurrentAccount();
        rows.addAll(
          await social.getPublicUsersByIds(
            ids.skip(offset).take(50).toList(growable: false),
            columns: 'id,username,display_name,avatar_url,bio',
          ),
        );
        requireCurrentAccount();
      }
      return rows
          .where(
            (row) =>
                connectedIds.contains(row['id']) &&
                row['username'] is String &&
                (row['username'] as String).isNotEmpty,
          )
          .map(
            (row) => MatchedUserPreview(
              user: AppUser(
                id: row['id'] as String,
                email: '',
                username: row['username'] as String,
                displayName: row['display_name'] as String?,
                avatarUrl: row['avatar_url'] as String?,
                bio: row['bio'] as String?,
              ),
              isFriend: acceptedIds.contains(row['id']),
              compatibility: 0,
              topArtists: const [],
              city: '',
              attendingEvents: 0,
            ),
          )
          .toList(growable: false);
    });

final publicFriendsProvider =
    FutureProvider.autoDispose<List<MatchedUserPreview>>((ref) async {
      final connections = await ref.watch(
        publicConnectionProfilesProvider.future,
      );
      return connections.where((user) => user.isFriend).toList(growable: false);
    });
