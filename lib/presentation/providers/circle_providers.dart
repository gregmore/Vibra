import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/circle.dart';
import '../../domain/entities/concert_match.dart';
import '../../domain/entities/event.dart';
import '../../domain/usecases/circle_suggestions.dart';
import 'core_providers.dart';
import 'musical_dna_providers.dart';

final myCirclesProvider = FutureProvider.autoDispose<List<Circle>>(
  (ref) => ref.watch(supabaseCirclesDatasourceProvider).myCircles(),
);

final circleInvitationsProvider =
    FutureProvider.autoDispose<List<CircleInvitation>>(
      (ref) => ref.watch(supabaseCirclesDatasourceProvider).myInvitations(),
    );

final circleByIdProvider = Provider.autoDispose.family<Circle?, String>((
  ref,
  id,
) {
  for (final c in ref.watch(myCirclesProvider).valueOrNull ?? const []) {
    if (c.id == id) return c;
  }
  return null;
});

/// VIBRA's proposals, built from Same Frequency people (mutual consent) and
/// the Musical DNA. Optional: any failure means no suggestions.
final circleSuggestionsProvider =
    FutureProvider.autoDispose<List<CircleSuggestion>>((ref) async {
      try {
        final candidates = await ref
            .watch(supabaseSameFrequencyDatasourceProvider)
            .candidates();
        final history = await ref
            .watch(myMusicalDnaHistoryProvider.future)
            .catchError((_) => const <Never>[]);
        return suggestCircles(
          candidates,
          history.isEmpty ? null : history.first,
        );
      } catch (_) {
        return const [];
      }
    });

final circleMessagesProvider = StreamProvider.autoDispose
    .family<List<CircleMessage>, String>(
      (ref, id) => ref.watch(supabaseCirclesDatasourceProvider).messages(id),
    );

final circleMembersProvider = FutureProvider.autoDispose
    .family<List<CircleMember>, String>(
      (ref, id) => ref.watch(supabaseCirclesDatasourceProvider).members(id),
    );

final circlePendingInvitesProvider = FutureProvider.autoDispose
    .family<List<PendingCircleInvite>, String>(
      (ref, id) =>
          ref.watch(supabaseCirclesDatasourceProvider).pendingInvites(id),
    );

final circlePlaylistProvider = FutureProvider.autoDispose
    .family<List<PlaylistItem>, String>(
      (ref, id) => ref.watch(supabaseCirclesDatasourceProvider).playlist(id),
    );

final circleEventsProvider = FutureProvider.autoDispose
    .family<List<Event>, String>(
      (ref, id) => ref.watch(supabaseCirclesDatasourceProvider).events(id),
    );

final circleInviteCandidatesProvider = FutureProvider.autoDispose
    .family<List<CirclePerson>, String>(
      (ref, id) =>
          ref.watch(supabaseCirclesDatasourceProvider).inviteCandidates(id),
    );

final circlePlansProvider = FutureProvider.autoDispose
    .family<List<CirclePlan>, String>(
      (ref, id) => ref.watch(supabaseCirclesDatasourceProvider).plans(id),
    );

final eventCirclesProvider = FutureProvider.autoDispose
    .family<List<EventCircle>, String>(
      (ref, eventId) =>
          ref.watch(supabaseCirclesDatasourceProvider).eventCircles(eventId),
    );
