import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/daily_vibe.dart';
import 'core_providers.dart';

class DailyVibeFeed extends AutoDisposeAsyncNotifier<List<DailyVibe>> {
  @override
  Future<List<DailyVibe>> build() =>
      ref.watch(supabaseDailyVibeDatasourceProvider).feed();

  void _replace(DailyVibe v) {
    final list = state.valueOrNull;
    if (list == null) return;
    state = AsyncData([for (final x in list) x.id == v.id ? v : x]);
  }

  Future<bool> react(DailyVibe v, String reaction) async {
    final on = !v.myReactions.contains(reaction);
    _replace(v.withReaction(reaction, on: on));
    try {
      await ref
          .read(supabaseDailyVibeDatasourceProvider)
          .toggleReaction(v.id, reaction);
      return true;
    } catch (_) {
      _replace(v);
      return false;
    }
  }

  Future<bool> save(DailyVibe v) async {
    _replace(v.copyWith(saved: true));
    try {
      await ref
          .read(supabaseDailyVibeDatasourceProvider)
          .saveToDiscoveries(v.id);
      ref.invalidate(discoveriesProvider);
      ref.invalidate(discoveredUrlsSourceProvider);
      return true;
    } catch (_) {
      _replace(v);
      return false;
    }
  }
}

final dailyVibeFeedProvider =
    AsyncNotifierProvider.autoDispose<DailyVibeFeed, List<DailyVibe>>(
      DailyVibeFeed.new,
    );

final vibeCommentsProvider = FutureProvider.autoDispose
    .family<List<VibeComment>, String>(
      (ref, id) => ref.watch(supabaseDailyVibeDatasourceProvider).comments(id),
    );

/// First page of my Discoveries; the screen loads the rest as it scrolls.
final discoveriesProvider = FutureProvider.autoDispose<List<Discovery>>(
  (ref) => ref.watch(supabaseDailyVibeDatasourceProvider).discoveries(),
);

/// Links of every saved song, to mark songs as saved.
final discoveredUrlsSourceProvider = FutureProvider.autoDispose<Set<String>>(
  (ref) => ref.watch(supabaseDailyVibeDatasourceProvider).discoveredUrls(),
);
