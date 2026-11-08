import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/artist_recommendation.dart';
import 'core_providers.dart';

/// "Discover my next artist" (docs/artist-discovery.md).
class ArtistDiscoveryController
    extends AutoDisposeAsyncNotifier<ArtistDiscoveryResult> {
  @override
  Future<ArtistDiscoveryResult> build() async {
    final result = await ref
        .read(supabaseArtistDiscoveryDatasourceProvider)
        .recommendations();
    _markShown(result.artists);
    return result;
  }

  void _markShown(List<ArtistRecommendation> artists) {
    ref
        .read(supabaseArtistDiscoveryDatasourceProvider)
        .markShown([for (final a in artists.take(30)) a.artistId])
        .catchError((_) {});
  }

  Future<void> refresh() async {
    state = const AsyncLoading<ArtistDiscoveryResult>().copyWithPrevious(state);
    state = await AsyncValue.guard(() async {
      final r = await ref
          .read(supabaseArtistDiscoveryDatasourceProvider)
          .recommendations(refresh: true);
      _markShown(r.artists);
      return r;
    });
  }

  /// Applies feedback at once; "not interested" and "known" remove the
  /// artist. Returns false (and restores it) if saving failed.
  Future<bool> feedback(
    ArtistRecommendation artist, {
    ArtistReaction? reaction,
    bool clearReaction = false,
    bool? saved,
  }) async {
    final current = state.valueOrNull;
    if (current == null) return false;
    final updated = artist.copyWith(
      reaction: reaction,
      clearReaction: clearReaction,
      saved: reaction == ArtistReaction.notInterested ? false : saved,
    );
    final removes =
        reaction == ArtistReaction.notInterested ||
        reaction == ArtistReaction.known;
    state = AsyncData(
      ArtistDiscoveryResult(
        artists: [
          for (final a in current.artists)
            if (a.artistId != artist.artistId) a else if (!removes) updated,
        ],
        emptyReason: current.emptyReason,
        providerUnavailable: current.providerUnavailable,
      ),
    );
    try {
      await ref
          .read(supabaseArtistDiscoveryDatasourceProvider)
          .feedback(
            artist.artistId,
            reaction: clearReaction ? null : updated.reaction,
            saved: saved,
          );
      if (saved != null) ref.invalidate(savedArtistsProvider);
      return true;
    } catch (_) {
      state = AsyncData(current);
      return false;
    }
  }
}

final artistDiscoveryProvider =
    AsyncNotifierProvider.autoDispose<
      ArtistDiscoveryController,
      ArtistDiscoveryResult
    >(ArtistDiscoveryController.new);

final savedArtistsProvider = FutureProvider.autoDispose<List<SavedArtist>>(
  (ref) => ref.watch(supabaseArtistDiscoveryDatasourceProvider).saved(),
);
