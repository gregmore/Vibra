import 'dart:typed_data';

import '../../core/errors/exceptions.dart';
import '../../domain/entities/feed_post.dart';
import '../../domain/entities/music_story.dart' show StoryItem;
import 'supabase_datasource.dart';
import 'supabase_music_stories_datasource.dart' show uploadPrivatePhoto;

/// VIBRA Feed (docs/vibra-feed.md). Search and posting go through the
/// feed-posts Edge Function, which takes Spotify metadata from Spotify.
/// Ranking happens in get_feed; this class only loads what it returns.
/// Page size of the saved-posts and a-person's-posts lists.
const feedListPageSize = 20;

class SupabaseFeedDatasource {
  const SupabaseFeedDatasource(this._supabase);

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
      'feed-posts',
      body: body,
    );
    if (response.status != 200) {
      throw ServerException(
        message: '${(response.data as Map?)?['error'] ?? 'feed_posts_failed'}',
        endpoint: 'feed-posts',
        statusCode: response.status,
      );
    }
    return response.data;
  }

  Future<List<StoryItem>> search(FeedItemType type, String query) async {
    final data = await _function({
      'action': 'search',
      'item_type': type.wire,
      'q': query,
    });
    return [
      for (final x in ((data as Map)['items'] as List? ?? const []))
        ?StoryItem.fromJson(x),
    ];
  }

  Future<String> uploadPhoto(Uint8List bytes) {
    _requireUser();
    return uploadPrivatePhoto(_supabase, 'feed-media', bytes);
  }

  Future<void> post({
    required FeedKind kind,
    FeedItemType? itemType,
    StoryItem? spotifyItem,
    String? linkUrl,
    String? linkTitle,
    String? linkSubtitle,
    String? mediaPath,
    String? eventId,
    String? body,
    int? rating,
    String? sharedPostId,
    bool everyone = true,
    bool commentsEnabled = true,
  }) => _function({
    'action': 'post',
    'kind': kind.wire,
    'item_type': ?itemType?.wire,
    'item_id': ?spotifyItem?.itemId,
    'url': ?linkUrl,
    'title': ?linkTitle,
    'subtitle': ?linkSubtitle,
    'media_path': ?mediaPath,
    'event_id': ?eventId,
    'body': ?body,
    'rating': ?rating,
    'shared_post_id': ?sharedPostId,
    'visibility': everyone ? 'everyone' : 'connections',
    'comments_enabled': commentsEnabled,
  });

  Future<List<FeedPost>> _byIds(List<String> ids) async {
    if (ids.isEmpty) return const [];
    return [
      for (final r in _rows(
        await _supabase.client.rpc('feed_post_rows', params: {'p_ids': ids}),
      ))
        ?FeedPost.fromRow(r),
    ];
  }

  /// One page of the feed. For you: pass the ids already shown; the
  /// chronological modes: pass the oldest created_at shown.
  Future<List<FeedPost>> feed(
    FeedMode mode, {
    DateTime? before,
    List<String> exclude = const [],
    int limit = 20,
  }) async {
    _requireUser();
    final ranked = [
      for (final r in _rows(
        await _supabase.client.rpc(
          'get_feed',
          params: {
            'p_mode': mode.wire,
            'p_before': before?.toUtc().toIso8601String(),
            'p_exclude': exclude.take(500).toList(),
            'p_limit': limit,
          },
        ),
      ))
        if (r['post_id'] is String)
          (id: r['post_id'] as String, reason: FeedReason.from(r['reason'])),
    ];
    return orderedFeed(ranked, await _byIds([for (final r in ranked) r.id]));
  }

  Future<FeedPost?> post1(String id) async => (await _byIds([id])).firstOrNull;

  /// A person's posts, newest first, [feedListPageSize] at a time; pass the
  /// oldest `createdAt` shown as [before] for the next page.
  Future<List<FeedPost>> userPosts(String userId, {DateTime? before}) async {
    final ids = [
      for (final x
          in (await _supabase.client.rpc(
                    'get_user_feed_posts',
                    params: {
                      'p_user': userId,
                      'p_before': before?.toUtc().toIso8601String(),
                      'p_limit': feedListPageSize,
                    },
                  )
                  as List? ??
              const []))
        if (x is String) x,
    ];
    final rows = await _byIds(ids);
    return orderedFeed([
      for (final id in ids) (id: id, reason: FeedReason.chronological),
    ], rows);
  }

  /// My bookmarks, most recently saved first, [feedListPageSize] at a time;
  /// pass the oldest `savedAt` shown as [before] for the next page.
  Future<List<FeedPost>> bookmarks({DateTime? before}) async {
    final saved = <String, DateTime?>{
      for (final r in _rows(
        await _supabase.client.rpc(
          'get_feed_bookmarks',
          params: {
            'p_before': before?.toUtc().toIso8601String(),
            'p_limit': feedListPageSize,
          },
        ),
      ))
        if (r['post_id'] is String)
          r['post_id'] as String: DateTime.tryParse('${r['saved_at']}'),
    };
    final ids = saved.keys.toList();
    return [
      for (final p in orderedFeed([
        for (final id in ids) (id: id, reason: FeedReason.chronological),
      ], await _byIds(ids)))
        p.copyWith(savedAt: saved[p.id]),
    ];
  }

  Future<void> toggleReaction(String postId, String reaction) =>
      _supabase.client.rpc(
        'toggle_feed_reaction',
        params: {'p_post': postId, 'p_reaction': reaction},
      );

  Future<void> setBookmark(String postId, bool saved) => _supabase.client.rpc(
    'set_feed_bookmark',
    params: {'p_post': postId, 'p_saved': saved},
  );

  Future<void> notInterested(String postId) => _supabase.client.rpc(
    'set_feed_not_interested',
    params: {'p_post': postId, 'p_dismissed': true},
  );

  Future<void> markSeen(List<String> ids) => ids.isEmpty
      ? Future.value()
      : _supabase.client.rpc(
          'mark_feed_seen',
          params: {'p_posts': ids.take(50).toList()},
        );

  Future<List<FeedComment>> comments(String postId) async => [
    for (final r in _rows(
      await _supabase.client.rpc(
        'get_feed_comments',
        params: {'p_post': postId},
      ),
    ))
      ?FeedComment.fromRow(r),
  ];

  Future<void> comment(String postId, String body, {String? parentId}) =>
      _supabase.client.rpc(
        'add_feed_comment',
        params: {'p_post': postId, 'p_body': body, 'p_parent': parentId},
      );

  Future<void> deleteComment(String commentId) => _supabase.client.rpc(
    'delete_feed_comment',
    params: {'p_comment': commentId},
  );

  Future<void> deleteMine(String postId) =>
      _supabase.client.rpc('delete_my_feed_post', params: {'p_post': postId});

  Future<void> updateMine(String postId, {bool? everyone, bool? comments}) =>
      _supabase.client.rpc(
        'update_my_feed_post',
        params: {
          'p_post': postId,
          'p_visibility': everyone == null
              ? null
              : everyone
              ? 'everyone'
              : 'connections',
          'p_comments_enabled': comments,
        },
      );

  Future<void> report({
    required String reportedId,
    required String reason,
    String? postId,
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
      'feed_post_id': ?postId,
      'feed_comment_id': ?commentId,
    });
  }
}
