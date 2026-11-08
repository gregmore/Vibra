import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart' show FunctionException;

import '../../core/errors/exceptions.dart';
import '../../domain/entities/music_story.dart';
import 'supabase_datasource.dart';

/// Uploads a photo through upload-image (decoded and re-encoded, so EXIF
/// metadata such as GPS is stripped) into a private bucket. Returns its path.
Future<String> uploadPrivatePhoto(
  SupabaseDatasource supabase,
  String bucket,
  Uint8List bytes,
) async {
  try {
    final response = await supabase.client.functions.invoke(
      'upload-image',
      queryParameters: {'bucket': bucket},
      body: bytes,
      headers: {'Content-Type': 'application/octet-stream'},
    );
    final path = (response.data as Map?)?['path'];
    if (path is! String) {
      throw const ServerException(message: 'upload_failed');
    }
    return path;
  } on FunctionException catch (e) {
    throw ServerException(
      message: e.status == 413 ? 'image_too_large' : 'invalid_image',
      statusCode: e.status,
      endpoint: 'upload-image',
    );
  }
}

/// Music Stories (docs/music-stories.md). Search and posting go through the
/// music-stories Edge Function, which takes Spotify metadata from Spotify.
/// Concert photos are re-encoded by upload-image (metadata stripped) into
/// the private story-media bucket.
class SupabaseMusicStoriesDatasource {
  const SupabaseMusicStoriesDatasource(this._supabase);

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
      'music-stories',
      body: body,
    );
    if (response.status != 200) {
      throw ServerException(
        message:
            '${(response.data as Map?)?['error'] ?? 'music_stories_failed'}',
        endpoint: 'music-stories',
        statusCode: response.status,
      );
    }
    return response.data;
  }

  Future<List<StoryItem>> search(StoryKind kind, String query) async {
    final data = await _function({
      'action': 'search',
      'kind': kind.wire,
      'q': query,
    });
    return [
      for (final x in ((data as Map)['items'] as List? ?? const []))
        ?StoryItem.fromJson(x),
    ];
  }

  /// Uploads a concert photo; returns its story-media path.
  Future<String> uploadPhoto(Uint8List bytes) {
    _requireUser();
    return uploadPrivatePhoto(_supabase, 'story-media', bytes);
  }

  Future<void> post({
    required StoryKind kind,
    StoryItem? spotifyItem,
    String? linkUrl,
    String? linkTitle,
    String? linkSubtitle,
    String? mediaPath,
    String? eventId,
    String? body,
    String background = 'aurora',
    bool? everyone,
    bool? allowReplies,
  }) => _function({
    'action': 'post',
    'kind': kind.wire,
    'item_id': ?spotifyItem?.itemId,
    'url': ?linkUrl,
    'title': ?linkTitle,
    'subtitle': ?linkSubtitle,
    'media_path': ?mediaPath,
    'event_id': ?eventId,
    'body': ?body,
    'background': background,
    if (everyone != null) 'visibility': everyone ? 'everyone' : 'connections',
    'allow_replies': ?allowReplies,
  });

  Future<List<StoryRingEntry>> ring() async {
    _requireUser();
    return [
      for (final r in _rows(await _supabase.client.rpc('get_story_ring')))
        ?StoryRingEntry.fromRow(r),
    ];
  }

  Future<List<MusicStory>> storiesOf(String userId) async => [
    for (final r in _rows(
      await _supabase.client.rpc(
        'get_user_music_stories',
        params: {'p_user': userId},
      ),
    ))
      ?MusicStory.fromRow(r),
  ];

  Future<void> markViewed(String storyId) => _supabase.client.rpc(
    'mark_music_story_viewed',
    params: {'p_story': storyId},
  );

  Future<void> toggleReaction(String storyId, String reaction) =>
      _supabase.client.rpc(
        'toggle_music_story_reaction',
        params: {'p_story': storyId, 'p_reaction': reaction},
      );

  Future<void> reply(String storyId, String body, {String? recipientId}) =>
      _supabase.client.rpc(
        'send_music_story_reply',
        params: {
          'p_story': storyId,
          'p_body': body,
          'p_recipient': recipientId,
        },
      );

  Future<List<StoryReply>> replies(String storyId) async => [
    for (final r in _rows(
      await _supabase.client.rpc(
        'get_music_story_replies',
        params: {'p_story': storyId},
      ),
    ))
      ?StoryReply.fromRow(r),
  ];

  Future<List<StoryPerson>> viewers(String storyId) async => [
    for (final r in _rows(
      await _supabase.client.rpc(
        'get_music_story_viewers',
        params: {'p_story': storyId},
      ),
    ))
      ?StoryPerson.fromRow(r),
  ];

  Future<void> deleteMine(String storyId) => _supabase.client.rpc(
    'delete_my_music_story',
    params: {'p_story': storyId},
  );

  Future<void> updateMine(String storyId, {bool? everyone, bool? replies}) =>
      _supabase.client.rpc(
        'update_my_music_story',
        params: {
          'p_story': storyId,
          'p_visibility': everyone == null
              ? null
              : everyone
              ? 'everyone'
              : 'connections',
          'p_allow_replies': replies,
        },
      );

  Future<StorySettings> settings() async {
    final user = _supabase.currentUser;
    if (user == null) return const StorySettings();
    final row = await _supabase.client
        .from('story_settings')
        .select()
        .eq('user_id', user.id)
        .maybeSingle();
    return StorySettings(
      everyone: row?['default_visibility'] == 'everyone',
      allowReplies: row?['allow_replies'] != false,
    );
  }

  Future<void> saveSettings(StorySettings s) => _supabase.client.rpc(
    'set_story_settings',
    params: {
      'p_default_visibility': s.everyone ? 'everyone' : 'connections',
      'p_allow_replies': s.allowReplies,
    },
  );

  Future<List<StoryPerson>> audience() async => [
    for (final r in _rows(
      await _supabase.client.rpc('get_story_audience_candidates'),
    ))
      ?StoryPerson.fromRow(r),
  ];

  Future<void> setHiddenFrom(String userId, bool hidden) =>
      _supabase.client.rpc(
        'set_story_hidden_from',
        params: {'p_viewer': userId, 'p_hidden': hidden},
      );

  Future<void> setMuted(String userId, bool muted) => _supabase.client.rpc(
    'set_story_muted',
    params: {'p_user': userId, 'p_muted': muted},
  );

  Future<void> report({
    required String reportedId,
    required String reason,
    String? storyId,
    String? replyId,
  }) async {
    final me = _supabase.currentUser;
    if (me == null) {
      throw const AuthException(message: 'Utente non autenticato');
    }
    await _supabase.client.from('reports').insert({
      'reporter_id': me.id,
      'reported_id': reportedId,
      'reason': reason,
      'music_story_id': ?storyId,
      'music_story_reply_id': ?replyId,
    });
  }
}
