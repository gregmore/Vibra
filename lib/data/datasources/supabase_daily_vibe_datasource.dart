import '../../core/errors/exceptions.dart';
import '../../domain/entities/daily_vibe.dart';
import '../../domain/entities/music_reaction.dart' show DiscoverySource;
import 'supabase_datasource.dart';

/// Daily Vibe (docs/daily-vibe.md). Search and posting go through the
/// daily-vibe Edge Function, which takes Spotify metadata from Spotify.
/// Page size of the Discoveries list.
const discoveryPageSize = 40;

class SupabaseDailyVibeDatasource {
  const SupabaseDailyVibeDatasource(this._supabase);

  final SupabaseDatasource _supabase;

  String? get currentUserId => _supabase.currentUser?.id;

  void _requireUser() {
    if (_supabase.currentUser == null) {
      throw const AuthException(message: 'Utente non autenticato');
    }
  }

  List<Map<String, dynamic>> _rows(Object? r) => r is List
      ? [
          for (final x in r)
            if (x is Map) Map<String, dynamic>.from(x),
        ]
      : const [];

  Future<dynamic> _function(Map<String, dynamic> body) async {
    _requireUser();
    final response = await _supabase.client.functions.invoke(
      'daily-vibe',
      body: body,
    );
    if (response.status != 200) {
      throw ServerException(
        message: '${(response.data as Map?)?['error'] ?? 'daily_vibe_failed'}',
        endpoint: 'daily-vibe',
        statusCode: response.status,
      );
    }
    return response.data;
  }

  Future<List<VibeTrack>> search(String query) async {
    final data = await _function({'action': 'search', 'q': query});
    return [
      for (final t in ((data as Map)['tracks'] as List? ?? const []))
        ?VibeTrack.fromJson(t),
    ];
  }

  Future<void> postSpotify(
    String trackId, {
    String? caption,
    bool expires = true,
    bool everyone = false,
  }) => _function({
    'action': 'post',
    'track_id': trackId,
    'caption': caption,
    'expires': expires,
    'visibility': everyone ? 'everyone' : 'connections',
  });

  Future<void> postLink({
    required String url,
    required String title,
    required String artist,
    String? caption,
    bool expires = true,
    bool everyone = false,
  }) => _function({
    'action': 'post',
    'url': url,
    'title': title,
    'artist': artist,
    'caption': caption,
    'expires': expires,
    'visibility': everyone ? 'everyone' : 'connections',
  });

  Future<List<DailyVibe>> feed() async {
    _requireUser();
    return [
      for (final r in _rows(
        await _supabase.client.rpc('get_daily_vibes', params: {'p_limit': 60}),
      ))
        ?DailyVibe.fromRow(r),
    ];
  }

  Future<void> deleteMine(String vibeId) =>
      _supabase.client.rpc('delete_my_daily_vibe', params: {'p_vibe': vibeId});

  Future<void> toggleReaction(String vibeId, String reaction) =>
      _supabase.client.rpc(
        'toggle_daily_vibe_reaction',
        params: {'p_vibe': vibeId, 'p_reaction': reaction},
      );

  Future<List<VibeComment>> comments(String vibeId) async => [
    for (final r in _rows(
      await _supabase.client.rpc(
        'get_daily_vibe_comments',
        params: {'p_vibe': vibeId},
      ),
    ))
      ?VibeComment.fromRow(r),
  ];

  Future<void> comment(String vibeId, String body, {String? parentId}) =>
      _supabase.client.rpc(
        'add_daily_vibe_comment',
        params: {'p_vibe': vibeId, 'p_body': body, 'p_parent': parentId},
      );

  Future<void> deleteComment(String commentId) => _supabase.client.rpc(
    'delete_daily_vibe_comment',
    params: {'p_comment': commentId},
  );

  Future<void> saveToDiscoveries(String vibeId) => _supabase.client.rpc(
    'save_vibe_to_discoveries',
    params: {'p_vibe': vibeId},
  );

  /// Saves a shared song from any song share (vibe, story, post, community).
  Future<void> saveTrack(DiscoverySource source, String id) =>
      _supabase.client.rpc(
        'save_track_to_discoveries',
        params: {'p_source': source.wire, 'p_id': id},
      );

  /// My Discoveries, newest first, [discoveryPageSize] at a time; pass the
  /// oldest `savedAt` shown as [before] for the next page.
  Future<List<Discovery>> discoveries({DateTime? before}) async {
    if (_supabase.currentUser == null) return const [];
    return [
      for (final r in _rows(
        await _supabase.client.rpc(
          'get_discoveries',
          params: {
            'p_limit': discoveryPageSize,
            'p_before': before?.toUtc().toIso8601String(),
          },
        ),
      ))
        if (r['id'] is String && VibeTrack.fromJson(r) != null)
          Discovery(
            r['id'] as String,
            VibeTrack.fromJson(r)!,
            source: r['source']?.toString() ?? 'vibe',
            viaUserId: r['via_user_id'] as String?,
            viaName: r['via_name'] as String?,
            savedAt: DateTime.tryParse('${r['saved_at']}'),
          ),
    ];
  }

  /// Links of every song in my Discoveries (one narrow column under the
  /// owner-only RLS policy), to mark songs as saved anywhere in the app.
  Future<Set<String>> discoveredUrls() async {
    final me = _supabase.currentUser;
    if (me == null) return const {};
    final rows = await _supabase.client
        .from('discovery_collection')
        .select('external_url')
        .eq('user_id', me.id)
        .limit(5000);
    return {
      for (final r in rows)
        if (r['external_url'] is String) r['external_url'] as String,
    };
  }

  Future<void> removeDiscovery(String id) =>
      _supabase.client.rpc('remove_discovery', params: {'p_id': id});

  Future<void> report({
    required String reportedId,
    required String reason,
    String? vibeId,
    String? commentId,
  }) async {
    final me = _supabase.currentUser;
    if (me == null) {
      throw const AuthException(message: 'Utente non autenticato');
    }
    await _supabase.client.from('reports').insert({
      'reporter_id': me.id,
      'reported_id': reportedId,
      'reason': reason,
      'daily_vibe_id': ?vibeId,
      'daily_vibe_comment_id': ?commentId,
    });
  }
}
