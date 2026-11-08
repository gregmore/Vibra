import '../../core/constants/db_tables.dart';
import '../../core/errors/exceptions.dart';
import '../../domain/entities/same_frequency.dart';
import 'supabase_datasource.dart';

/// Same Frequency (docs/same-frequency.md): candidates with their signals,
/// impressions for rotation, saved profiles and the shared-events opt-in.
class SupabaseSameFrequencyDatasource {
  const SupabaseSameFrequencyDatasource(this._supabase);

  final SupabaseDatasource _supabase;

  String _requireUserId() {
    final user = _supabase.currentUser;
    if (user == null) {
      throw const AuthException(message: 'Utente non autenticato');
    }
    return user.id;
  }

  Future<List<FrequencyCandidate>> candidates() async {
    _requireUserId();
    final rows = await _supabase.client.rpc(
      'get_same_frequency',
      params: {'p_limit': 80},
    );
    final people = [
      for (final row in List<Map<String, dynamic>>.from(rows as List))
        ?FrequencyCandidate.fromRow(row),
    ];
    return _withSharedCommunities(people);
  }

  /// Adds the communities the caller shares with each person. Optional
  /// signal: if it fails, the list is returned without it.
  Future<List<FrequencyCandidate>> _withSharedCommunities(
    List<FrequencyCandidate> people,
  ) async {
    if (people.isEmpty) return people;
    try {
      final rows = await _supabase.client.rpc(
        'get_shared_communities',
        params: {
          'p_users': [for (final p in people) p.userId],
        },
      );
      final shared = <String, List<String>>{
        for (final r in List<Map<String, dynamic>>.from(rows as List))
          if (r['user_id'] is String)
            r['user_id'] as String: [
              if (r['names'] is List)
                ...(r['names'] as List).whereType<String>(),
            ],
      };
      return [
        for (final p in people)
          shared[p.userId] == null
              ? p
              : p.copyWith(sharedCommunities: shared[p.userId]),
      ];
    } catch (_) {
      return people;
    }
  }

  /// People the user actually saw; the server counts one view per 6 hours.
  Future<void> recordViews(List<String> userIds) async {
    _requireUserId();
    if (userIds.isEmpty) return;
    await _supabase.client.rpc(
      'record_same_frequency_views',
      params: {'p_user_ids': userIds.take(30).toList()},
    );
  }

  Future<void> setSaved(String otherUserId, {required bool saved}) async {
    final userId = _requireUserId();
    final table = _supabase.client.from(DbTables.savedProfiles);
    if (saved) {
      await table.upsert({
        'user_id': userId,
        'saved_user_id': otherUserId,
      }, onConflict: 'user_id,saved_user_id');
    } else {
      await table
          .delete()
          .eq('user_id', userId)
          .eq('saved_user_id', otherUserId);
    }
  }

  Future<List<FrequencyCandidate>> savedProfiles() async {
    _requireUserId();
    final rows = await _supabase.client.rpc('get_saved_profiles');
    return [
      for (final row in List<Map<String, dynamic>>.from(rows as List))
        ?FrequencyCandidate.fromRow({...row, 'saved': true}),
    ];
  }

  Future<bool> sharesEvents() async {
    final userId = _requireUserId();
    final row = await _supabase.client
        .from(DbTables.privacyPreferences)
        .select('same_frequency_events')
        .eq('user_id', userId)
        .maybeSingle();
    return row?['same_frequency_events'] == true;
  }

  Future<void> setSharesEvents(bool value) async {
    final userId = _requireUserId();
    await _supabase.client.from(DbTables.privacyPreferences).upsert({
      'user_id': userId,
      'same_frequency_events': value,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }, onConflict: 'user_id');
  }
}
