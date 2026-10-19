import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/exceptions.dart';
import '../../domain/entities/matched_user_preview.dart';
import 'core_providers.dart';

/// A literal, bounded name/username search independent of Spotify matching.
final publicUsersProvider = FutureProvider.autoDispose
    .family<List<MatchedUserPreview>, String>((ref, query) async {
      final source = ref.watch(supabaseDatasourceProvider);
      final accountId = source.currentUser?.id;
      var active = true;
      final authSubscription = source.authStateChanges.listen((event) {
        if (event.session?.user.id != accountId) ref.invalidateSelf();
      });
      ref.onDispose(() {
        active = false;
        authSubscription.cancel();
      });
      // Keep observing sign-in even when the first read had no account.
      if (accountId == null) return const [];
      void requireCurrentAccount() {
        if (!active || source.currentUser?.id != accountId) {
          throw const AuthException(message: 'La sessione è cambiata.');
        }
      }

      requireCurrentAccount();
      try {
        final users = await ref
            .watch(supabaseSocialDatasourceProvider)
            .searchPublicUsers(
              query: String.fromCharCodes(query.trim().runes.take(100)),
            );
        requireCurrentAccount();
        return users
            .map(
              (user) => MatchedUserPreview(
                user: user,
                // These facts are unavailable in the public projection.
                compatibility: 0,
                topArtists: const [],
                city: '',
                attendingEvents: 0,
              ),
            )
            .toList(growable: false);
      } catch (_) {
        requireCurrentAccount();
        rethrow;
      }
    });
