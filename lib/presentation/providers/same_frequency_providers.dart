import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/same_frequency.dart';
import '../../domain/usecases/same_frequency.dart';
import 'app_state_providers.dart';
import 'core_providers.dart';

/// Clock seam for tests.
final sameFrequencyClockProvider = Provider<DateTime Function()>(
  (ref) => DateTime.now,
);

/// The caller's Same Frequency list. Ranked once per load so it stays
/// stable while the user is looking at it; the people shown are recorded
/// so the next visit rotates.
class SameFrequencyController
    extends AutoDisposeAsyncNotifier<FrequencyResult> {
  @override
  Future<FrequencyResult> build() async {
    final source = ref.watch(supabaseSameFrequencyDatasourceProvider);
    final result = rankSameFrequency(
      await source.candidates(),
      now: ref.read(sameFrequencyClockProvider)().toUtc(),
    );
    final shown = [for (final p in result.people) p.userId];
    // Rotation bookkeeping only; a failure must not hide the list.
    source.recordViews(shown).catchError((_) {});
    return result;
  }

  void _replace(
    String userId,
    FrequencyCandidate? Function(FrequencyCandidate) f,
  ) {
    final current = state.valueOrNull;
    if (current == null) return;
    final people = <FrequencyCandidate>[
      for (final p in current.people)
        if (p.userId != userId) p else ?f(p),
    ];
    final removed = current.people.length - people.length;
    state = AsyncData(
      FrequencyResult(
        people: people,
        strongCount: current.strongCount - removed,
      ),
    );
  }

  /// Optimistic; returns false (and rolls back) when saving fails.
  Future<bool> toggleSaved(FrequencyCandidate person) async {
    final next = !person.saved;
    _replace(person.userId, (p) => p.copyWith(saved: next));
    try {
      await ref
          .read(supabaseSameFrequencyDatasourceProvider)
          .setSaved(person.userId, saved: next);
      ref.invalidate(savedProfilesProvider);
      return true;
    } catch (_) {
      _replace(person.userId, (p) => p.copyWith(saved: person.saved));
      return false;
    }
  }

  /// Sends a Vibra (connection request) with the existing social flow; the
  /// person then leaves the list, as in the affinity deck.
  Future<void> sendVibra(String userId) async {
    await ref.read(matchedUsersProvider.notifier).sendVibra(userId);
    _replace(userId, (_) => null);
  }
}

final sameFrequencyProvider =
    AsyncNotifierProvider.autoDispose<SameFrequencyController, FrequencyResult>(
      SameFrequencyController.new,
    );

/// The same ranking for a glance on Home (avatars and a count). It records
/// no views: only the Same Frequency screen, where cards are actually shown,
/// counts towards rotation.
final sameFrequencyPreviewProvider =
    FutureProvider.autoDispose<FrequencyResult>(
      (ref) async => rankSameFrequency(
        await ref.watch(supabaseSameFrequencyDatasourceProvider).candidates(),
        now: ref.read(sameFrequencyClockProvider)().toUtc(),
      ),
    );

final savedProfilesProvider =
    FutureProvider.autoDispose<List<FrequencyCandidate>>(
      (ref) =>
          ref.watch(supabaseSameFrequencyDatasourceProvider).savedProfiles(),
    );

class SharedEventsOptIn extends AutoDisposeAsyncNotifier<bool> {
  @override
  Future<bool> build() =>
      ref.watch(supabaseSameFrequencyDatasourceProvider).sharesEvents();

  Future<bool> set(bool value) async {
    final previous = state.valueOrNull ?? false;
    state = AsyncData(value);
    try {
      await ref
          .read(supabaseSameFrequencyDatasourceProvider)
          .setSharesEvents(value);
      ref.invalidate(sameFrequencyProvider);
      return true;
    } catch (_) {
      state = AsyncData(previous);
      return false;
    }
  }
}

final sharedEventsOptInProvider =
    AsyncNotifierProvider.autoDispose<SharedEventsOptIn, bool>(
      SharedEventsOptIn.new,
    );
