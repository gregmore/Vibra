import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core_providers.dart';

/// The caller's hand-picked genres (key → intensity). Empty on any error so
/// screens fall back to the "pick your genres" invitation.
final myGenrePreferencesProvider = FutureProvider.autoDispose<Map<String, int>>(
  (ref) async {
    try {
      return await ref
          .watch(supabaseSocialDatasourceProvider)
          .getMyGenrePreferences();
    } catch (_) {
      return const {};
    }
  },
);
