import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/music_radar.dart';
import 'app_state_providers.dart';
import 'core_providers.dart';
import 'location_provider.dart';

class MusicRadarController extends AutoDisposeAsyncNotifier<MusicRadar> {
  @override
  Future<MusicRadar> build() =>
      ref.watch(supabaseMusicRadarDatasourceProvider).radar();

  /// Saves one setting, then reloads the radar. Turning the radar on also
  /// refreshes the private server location (only with location consent).
  Future<bool> saveSettings({
    bool? enabled,
    bool? visible,
    int? distanceKm,
    RadarPrecision? precision,
  }) async {
    final previous = state.valueOrNull;
    if (previous != null) {
      state = AsyncData(
        previous.copyWith(
          settings: previous.settings.copyWith(
            enabled: enabled,
            visible: visible,
            distanceKm: distanceKm,
            precision: precision,
          ),
        ),
      );
    }
    try {
      await ref
          .read(supabaseMusicRadarDatasourceProvider)
          .updateSettings(
            enabled: enabled,
            visible: visible,
            distanceKm: distanceKm,
            precision: precision,
          );
      if (enabled == true) {
        try {
          final _ = await ref.refresh(userLocationProvider.future);
        } catch (_) {}
      }
      ref.invalidateSelf();
      return true;
    } catch (_) {
      if (previous != null) state = AsyncData(previous);
      return false;
    }
  }

  Future<void> sendVibra(String userId) async {
    await ref.read(matchedUsersProvider.notifier).sendVibra(userId);
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(
      current.copyWith(
        people: [
          for (final p in current.people)
            p.candidate.userId == userId
                ? RadarPerson(p.candidate, connection: 'pending')
                : p,
        ],
      ),
    );
  }

  Future<bool> toggleSaved(RadarPerson person) async {
    final current = state.valueOrNull;
    final next = !person.candidate.saved;
    void apply(bool saved) {
      final now = state.valueOrNull ?? current;
      if (now == null) return;
      state = AsyncData(
        now.copyWith(
          people: [
            for (final p in now.people)
              p.candidate.userId == person.candidate.userId
                  ? RadarPerson(
                      p.candidate.copyWith(saved: saved),
                      connection: p.connection,
                    )
                  : p,
          ],
        ),
      );
    }

    apply(next);
    try {
      await ref
          .read(supabaseSameFrequencyDatasourceProvider)
          .setSaved(person.candidate.userId, saved: next);
      return true;
    } catch (_) {
      apply(!next);
      return false;
    }
  }
}

final musicRadarProvider =
    AsyncNotifierProvider.autoDispose<MusicRadarController, MusicRadar>(
      MusicRadarController.new,
    );
