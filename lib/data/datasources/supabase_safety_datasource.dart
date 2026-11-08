import '../../core/errors/exceptions.dart';
import '../../domain/entities/safety.dart';
import 'supabase_datasource.dart';

/// Social safety (docs/safety.md). Every check happens on the server; this
/// class only calls it.
class SupabaseSafetyDatasource {
  const SupabaseSafetyDatasource(this._supabase);

  final SupabaseDatasource _supabase;

  String _me() {
    final user = _supabase.currentUser;
    if (user == null) {
      throw const AuthException(message: 'Utente non autenticato');
    }
    return user.id;
  }

  Future<SafetyOverview> overview() async {
    _me();
    return SafetyOverview.fromJson(
      await _supabase.client.rpc('get_my_safety_overview'),
    );
  }

  Future<List<BlockedUser>> blocked() async {
    _me();
    final rows = await _supabase.client.rpc('get_my_blocked_users');
    return [
      for (final r in (rows is List ? rows : const []))
        if (r is Map && r['user_id'] is String)
          BlockedUser(
            userId: r['user_id'] as String,
            username: r['username']?.toString() ?? 'user',
            displayName: r['display_name'] as String?,
            avatarUrl: r['avatar_url'] as String?,
            blockedAt: DateTime.tryParse('${r['blocked_at']}'),
          ),
    ];
  }

  Future<void> block(String userId) {
    _me();
    return _supabase.client.rpc('block_user', params: {'p_user': userId});
  }

  Future<void> unblock(String userId) {
    _me();
    return _supabase.client.rpc('unblock_user', params: {'p_user': userId});
  }

  /// Reports a person (not a specific post or message).
  Future<void> reportUser(String userId, String reason, {String? details}) {
    final me = _me();
    return _supabase.client.from('reports').insert({
      'reporter_id': me,
      'reported_id': userId,
      'reason': reason,
      if (details != null && details.trim().isNotEmpty)
        'description': details.trim(),
    });
  }
}
