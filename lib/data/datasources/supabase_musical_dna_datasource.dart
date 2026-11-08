import '../../core/constants/db_tables.dart';
import '../../core/errors/exceptions.dart';
import '../../domain/entities/musical_dna.dart';
import '../../domain/entities/taste_evolution.dart';
import 'supabase_datasource.dart';

/// Musical DNA snapshots (docs/musical-dna.md). The DNA is computed and
/// written only by the server; the app reads it and sets who may see it.
class SupabaseMusicalDnaDatasource {
  const SupabaseMusicalDnaDatasource(this._supabase);

  final SupabaseDatasource _supabase;

  String _requireUserId() {
    final user = _supabase.currentUser;
    if (user == null) {
      throw const AuthException(message: 'Utente non autenticato');
    }
    return user.id;
  }

  /// The caller's snapshots, newest first (RLS: owner only).
  Future<List<MusicalDna>> myHistory({int limit = 120}) async {
    final userId = _requireUserId();
    final rows = await _supabase.client
        .from(DbTables.musicalDnaSnapshots)
        .select('captured_on, dna')
        .eq('user_id', userId)
        .order('captured_on', ascending: false)
        .limit(limit);
    return [
      for (final row in List<Map<String, dynamic>>.from(rows))
        ?MusicalDna.fromJson(
          row['dna'],
          capturedOn: DateTime.tryParse('${row['captured_on']}'),
        ),
    ];
  }

  /// Someone's current DNA, or null when it does not exist or its owner's
  /// visibility setting hides it from the caller (get_musical_dna).
  Future<MusicalDna?> dnaOf(String userId) async {
    _requireUserId();
    final result = await _supabase.client.rpc(
      'get_musical_dna',
      params: {'p_user_id': userId},
    );
    if (result is! Map) return null;
    return MusicalDna.fromJson(
      result['dna'],
      capturedOn: DateTime.tryParse('${result['captured_on']}'),
    );
  }

  /// Asks the server to rebuild the caller's DNA (and affinities) from their
  /// current Spotify profile and picked genres.
  Future<void> refresh() async {
    _requireUserId();
    final response = await _supabase.client.functions.invoke('calculate-match');
    if (response.status != 200) {
      throw ServerException(
        message: 'musical_dna_refresh_failed',
        endpoint: 'calculate-match',
        statusCode: response.status,
      );
    }
  }

  Future<DnaVisibility> myVisibility() async {
    final userId = _requireUserId();
    final row = await _supabase.client
        .from(DbTables.privacyPreferences)
        .select('musical_dna_visibility')
        .eq('user_id', userId)
        .maybeSingle();
    return DnaVisibility.fromName(row?['musical_dna_visibility']);
  }

  /// Taste Evolution (docs/taste-evolution.md): real snapshots compared
  /// over the last [days].
  Future<TasteEvolution> evolution(int days) async {
    _requireUserId();
    final raw = await _supabase.client.rpc(
      'get_taste_evolution',
      params: {'p_days': days},
    );
    return TasteEvolution.fromJson(
      raw is Map ? Map<String, dynamic>.from(raw) : const {},
    );
  }

  /// Off deletes past snapshots and keeps only the current DNA from then on.
  Future<void> setTasteHistory(bool enabled) async {
    _requireUserId();
    await _supabase.client.rpc(
      'set_taste_history',
      params: {'p_enabled': enabled},
    );
  }

  Future<void> setMyVisibility(DnaVisibility visibility) async {
    final userId = _requireUserId();
    await _supabase.client.from(DbTables.privacyPreferences).upsert({
      'user_id': userId,
      'musical_dna_visibility': visibility.name,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }, onConflict: 'user_id');
  }
}
