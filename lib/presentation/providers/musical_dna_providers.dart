import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../domain/entities/musical_dna.dart';
import '../../domain/entities/taste_evolution.dart';
import 'core_providers.dart';

/// The caller's DNA snapshots, newest first. When none exists yet (first
/// visit after the feature shipped, or after a Spotify disconnect) the
/// server is asked once to build it from the data the user already has.
final myMusicalDnaHistoryProvider =
    FutureProvider.autoDispose<List<MusicalDna>>((ref) async {
      final source = ref.watch(supabaseMusicalDnaDatasourceProvider);
      final history = await source.myHistory();
      if (history.isNotEmpty || !AppConstants.spotifyEnabled) return history;
      try {
        await source.refresh();
      } catch (_) {
        return history;
      }
      return source.myHistory();
    });

/// Another user's current DNA, or null if hidden by their visibility setting.
final userMusicalDnaProvider = FutureProvider.autoDispose
    .family<MusicalDna?, String>((ref, userId) async {
      try {
        return await ref
            .watch(supabaseMusicalDnaDatasourceProvider)
            .dnaOf(userId);
      } catch (_) {
        return null;
      }
    });

class DnaVisibilityNotifier extends AutoDisposeAsyncNotifier<DnaVisibility> {
  @override
  Future<DnaVisibility> build() =>
      ref.watch(supabaseMusicalDnaDatasourceProvider).myVisibility();

  /// Optimistic: the choice shows at once and rolls back if saving fails.
  Future<bool> select(DnaVisibility visibility) async {
    final previous = state.valueOrNull;
    if (previous == visibility) return true;
    state = AsyncData(visibility);
    try {
      await ref
          .read(supabaseMusicalDnaDatasourceProvider)
          .setMyVisibility(visibility);
      return true;
    } catch (_) {
      state = previous == null
          ? AsyncError('musical_dna_visibility_failed', StackTrace.current)
          : AsyncData(previous);
      return false;
    }
  }
}

final dnaVisibilityProvider =
    AsyncNotifierProvider.autoDispose<DnaVisibilityNotifier, DnaVisibility>(
      DnaVisibilityNotifier.new,
    );

/// Taste Evolution for one period (docs/taste-evolution.md).
final tasteEvolutionProvider = FutureProvider.autoDispose
    .family<TasteEvolution, TastePeriod>(
      (ref, period) => ref
          .watch(supabaseMusicalDnaDatasourceProvider)
          .evolution(period.days),
    );
