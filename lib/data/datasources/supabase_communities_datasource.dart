import '../../core/errors/exceptions.dart';
import '../../domain/entities/community.dart';
import '../../domain/entities/event.dart';
import '../mappers/domain_mappers.dart';
import '../models/event_model.dart';
import 'supabase_datasource.dart';

/// Musical communities (docs/communities.md). Every write is a server
/// function that enforces membership, bans, blocks, rate limits and spam
/// rules; the app never writes the tables directly.
class SupabaseCommunitiesDatasource {
  const SupabaseCommunitiesDatasource(this._supabase);

  final SupabaseDatasource _supabase;

  String _me() {
    final user = _supabase.currentUser;
    if (user == null) {
      throw const AuthException(message: 'Utente non autenticato');
    }
    return user.id;
  }

  static Event? parseEvent(Map<String, dynamic> row) {
    try {
      return EventModel.fromJson(row).toEntity();
    } catch (_) {
      return null;
    }
  }

  Future<dynamic> _rpc(String fn, [Map<String, dynamic>? params]) {
    _me();
    return _supabase.client.rpc(fn, params: params);
  }

  List<Map<String, dynamic>> _rows(Object? result) => result is List
      ? [
          for (final r in result)
            if (r is Map) Map<String, dynamic>.from(r),
        ]
      : const [];

  String? get currentUserId => _supabase.currentUser?.id;

  Future<List<Community>> communities({String? search}) async => [
    for (final r in _rows(
      await _rpc('get_communities', {'p_search': search, 'p_limit': 200}),
    ))
      ?Community.fromRow(r),
  ];

  Future<String> create({
    required String name,
    required String description,
    required CommunityKind kind,
    String? genreKey,
    String? genreFamily,
    String? artistName,
  }) async =>
      '${await _rpc('create_community', {'p_name': name, 'p_description': description, 'p_kind': kind.name, 'p_genre_key': genreKey, 'p_genre_family': genreFamily, 'p_artist_name': artistName})}';

  Future<void> join(String communityId) =>
      _rpc('join_community', {'p_community': communityId});

  Future<void> leave(String communityId) =>
      _rpc('leave_community', {'p_community': communityId});

  Future<List<CommunityPost>> feed(
    String communityId, {
    CommunityPostKind? kind,
    DateTime? before,
  }) async => [
    for (final r in _rows(
      await _rpc('get_community_feed', {
        'p_community': communityId,
        'p_kind': kind?.name,
        'p_before': before?.toUtc().toIso8601String(),
        'p_limit': 30,
      }),
    ))
      ?CommunityPost.fromRow(r, parseEvent: parseEvent),
  ];

  Future<String> createPost({
    required String communityId,
    required CommunityPostKind kind,
    String? title,
    String body = '',
    SharedMusic? music,
    String? eventId,
  }) async =>
      '${await _rpc('create_community_post', {
        'p_community': communityId,
        'p_kind': kind.name,
        'p_title': title,
        'p_body': body,
        'p_music': music == null ? null : {'url': music.url, 'title': music.title, 'artist': music.artist},
        'p_event_id': eventId,
      })}';

  Future<List<CommunityComment>> comments(String postId) async => [
    for (final r in _rows(
      await _rpc('get_community_comments', {'p_post': postId}),
    ))
      ?CommunityComment.fromRow(r),
  ];

  Future<void> comment(String postId, String body) =>
      _rpc('create_community_comment', {'p_post': postId, 'p_body': body});

  Future<bool> toggleReaction(String postId, String reaction) async =>
      await _rpc('toggle_community_reaction', {
        'p_post': postId,
        'p_reaction': reaction,
      }) ==
      true;

  Future<void> deleteOwn({String? postId, String? commentId}) => _rpc(
    'delete_own_community_content',
    {'p_post': postId, 'p_comment': commentId},
  );

  Future<List<CommunityMember>> members(String communityId) async => [
    for (final r in _rows(
      await _rpc('get_community_members', {
        'p_community': communityId,
        'p_limit': 200,
      }),
    ))
      ?CommunityMember.fromRow(r),
  ];

  Future<List<Event>> events(String communityId) async => [
    for (final r in _rows(
      await _rpc('get_community_events', {'p_community': communityId}),
    ))
      ?parseEvent(r),
  ];

  // ── Moderation ───────────────────────────────────────────────────────
  Future<void> moderate({
    required bool remove,
    String? postId,
    String? commentId,
    String? reason,
  }) => _rpc('moderate_community_content', {
    'p_action': remove ? 'remove' : 'restore',
    'p_post': postId,
    'p_comment': commentId,
    'p_reason': reason,
  });

  Future<void> setBan(
    String communityId,
    String userId, {
    required bool banned,
  }) => _rpc('set_community_ban', {
    'p_community': communityId,
    'p_user': userId,
    'p_banned': banned,
  });

  Future<void> setRole(String communityId, String userId, CommunityRole role) =>
      _rpc('set_community_role', {
        'p_community': communityId,
        'p_user': userId,
        'p_role': role.name,
      });

  Future<List<ModerationItem>> moderationQueue(String communityId) async => [
    for (final r in _rows(
      await _rpc('get_community_moderation_queue', {
        'p_community': communityId,
      }),
    ))
      ?ModerationItem.fromRow(r),
  ];

  /// Reports go to the shared reports table (validated and rate-limited by
  /// the server; three reports hold the content for review).
  Future<void> report({
    required String reportedId,
    required String reason,
    String? description,
    String? postId,
    String? commentId,
  }) async {
    final me = _me();
    await _supabase.client.from('reports').insert({
      'reporter_id': me,
      'reported_id': reportedId,
      'reason': reason,
      'description': ?description,
      'community_post_id': ?postId,
      'community_comment_id': ?commentId,
    });
  }
}
