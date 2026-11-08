import '../../core/errors/exceptions.dart';
import '../../domain/entities/circle.dart';
import '../../domain/entities/concert_match.dart';
import '../../domain/entities/event.dart';
import '../mappers/domain_mappers.dart';
import '../models/event_model.dart';
import 'supabase_datasource.dart';

/// VIBRA Circles (docs/circles.md). Every write is a server function that
/// enforces membership, admin rights, consent (invitations) and limits.
class SupabaseCirclesDatasource {
  const SupabaseCirclesDatasource(this._supabase);

  final SupabaseDatasource _supabase;

  String? get currentUserId => _supabase.currentUser?.id;

  Future<dynamic> _rpc(String fn, [Map<String, dynamic>? params]) {
    if (_supabase.currentUser == null) {
      throw const AuthException(message: 'Utente non autenticato');
    }
    return _supabase.client.rpc(fn, params: params);
  }

  List<Map<String, dynamic>> _rows(Object? r) => r is List
      ? [
          for (final x in r)
            if (x is Map) Map<String, dynamic>.from(x),
        ]
      : const [];

  Future<List<Circle>> myCircles() async => [
    for (final r in _rows(await _rpc('get_my_circles'))) ?Circle.fromRow(r),
  ];

  Future<List<CircleInvitation>> myInvitations() async => [
    for (final r in _rows(await _rpc('get_my_circle_invitations')))
      ?CircleInvitation.fromRow(r),
  ];

  Future<String> create({
    required String name,
    required String description,
    required CircleBasis basis,
    String? genreKey,
    String? artistName,
    String? eventId,
    String? topic,
  }) async =>
      '${await _rpc('create_circle', {'p_name': name, 'p_description': description, 'p_basis': basis.name, 'p_genre_key': genreKey, 'p_artist_name': artistName, 'p_event_id': eventId, 'p_topic': topic})}';

  Future<void> update(String id, {String? name, String? description}) => _rpc(
    'update_circle',
    {'p_circle': id, 'p_name': name, 'p_description': description},
  );

  Future<void> leave(String id) => _rpc('leave_circle', {'p_circle': id});

  Future<void> setMuted(String id, bool muted) =>
      _rpc('set_circle_muted', {'p_circle': id, 'p_muted': muted});

  Future<void> invite(String circleId, String userId) =>
      _rpc('invite_to_circle', {'p_circle': circleId, 'p_user': userId});

  /// Returns the circle id when accepted.
  Future<String?> respond(String invitationId, {required bool accept}) async {
    final r = await _rpc('respond_circle_invitation', {
      'p_invitation': invitationId,
      'p_accept': accept,
    });
    return r is String ? r : null;
  }

  Future<void> revoke(String invitationId) =>
      _rpc('revoke_circle_invitation', {'p_invitation': invitationId});

  Future<List<CirclePerson>> inviteCandidates(String circleId) async => [
    for (final r in _rows(
      await _rpc('get_circle_invite_candidates', {'p_circle': circleId}),
    ))
      ?CirclePerson.fromRow(r),
  ];

  Future<List<PendingCircleInvite>> pendingInvites(String circleId) async => [
    for (final r in _rows(
      await _rpc('get_circle_pending_invitations', {'p_circle': circleId}),
    ))
      if (r['id'] is String &&
          CirclePerson.fromRow(r, idKey: 'invitee_id') != null)
        PendingCircleInvite(
          r['id'] as String,
          CirclePerson.fromRow(r, idKey: 'invitee_id')!,
        ),
  ];

  Future<List<CircleMember>> members(String circleId) async => [
    for (final r in _rows(
      await _rpc('get_circle_members', {'p_circle': circleId}),
    ))
      if (CirclePerson.fromRow(r) case final p?)
        CircleMember(
          p,
          isAdmin: r['role'] == 'admin',
          eventStatus: r['event_status'] as String?,
        ),
  ];

  Future<void> manageMember(String circleId, String userId, String action) =>
      _rpc('manage_circle_member', {
        'p_circle': circleId,
        'p_user': userId,
        'p_action': action,
      });

  /// Live chat: initial page plus Realtime inserts, newest first. RLS hides
  /// messages of people the user blocked.
  Stream<List<CircleMessage>> messages(String circleId) => _supabase.client
      .from('circle_messages')
      .stream(primaryKey: ['id'])
      .eq('circle_id', circleId)
      .order('created_at', ascending: false)
      .limit(200)
      .map(
        (rows) => [
          for (final r in rows)
            if (r['removed_at'] == null) ?CircleMessage.fromRow(r),
        ],
      );

  Future<void> send(String circleId, String body) =>
      _rpc('send_circle_message', {'p_circle': circleId, 'p_body': body});

  Future<List<PlaylistItem>> playlist(String circleId) async => [
    for (final r in _rows(
      await _rpc('get_circle_playlist', {'p_circle': circleId}),
    ))
      ?PlaylistItem.fromRow(r),
  ];

  Future<void> addToPlaylist(
    String circleId, {
    required String url,
    String? title,
    String? artist,
  }) => _rpc('add_circle_playlist_item', {
    'p_circle': circleId,
    'p_url': url,
    'p_title': title,
    'p_artist': artist,
  });

  Future<void> removeFromPlaylist(String itemId) =>
      _rpc('remove_circle_playlist_item', {'p_item': itemId});

  Future<List<Event>> events(String circleId) async => [
    for (final r in _rows(
      await _rpc('get_circle_events', {'p_circle': circleId}),
    ))
      ?_event(r),
  ];

  Future<void> setEvent(String circleId, String eventId, bool shared) => _rpc(
    'set_circle_event',
    {'p_circle': circleId, 'p_event': eventId, 'p_shared': shared},
  );

  Future<List<CirclePlan>> plans(String circleId) async => [
    for (final r in _rows(
      await _rpc('get_circle_plans', {'p_circle': circleId}),
    ))
      ?CirclePlan.fromRow(r),
  ];

  Future<void> addPlan(
    String circleId, {
    required String title,
    DateTime? startsAt,
    String? note,
    String? eventId,
  }) => _rpc('add_circle_plan', {
    'p_circle': circleId,
    'p_title': title,
    'p_starts_at': startsAt?.toUtc().toIso8601String(),
    'p_note': note,
    'p_event': eventId,
  });

  Future<void> togglePlan(String planId) =>
      _rpc('toggle_circle_plan', {'p_plan': planId});

  Future<void> removePlan(String planId) =>
      _rpc('remove_circle_plan', {'p_plan': planId});

  Future<void> setEventStatus(String circleId, String? status) => _rpc(
    'set_circle_event_status',
    {'p_circle': circleId, 'p_status': status},
  );

  Future<void> removeMessage(String messageId) =>
      _rpc('remove_circle_message', {'p_message': messageId});

  Future<void> restoreMessage(String messageId) =>
      _rpc('restore_circle_message', {'p_message': messageId});

  /// Report a message, or a member (with [messageId] null), to Vibra's
  /// moderation. Two reports hold a message for the circle's admins.
  Future<void> report({
    required String circleId,
    required String reportedId,
    required String reason,
    String? messageId,
  }) async {
    final me = _supabase.currentUser;
    if (me == null) {
      throw const AuthException(message: 'Utente non autenticato');
    }
    await _supabase.client.from('reports').insert({
      'reporter_id': me.id,
      'reported_id': reportedId,
      'reason': reason,
      'circle_id': circleId,
      'circle_message_id': ?messageId,
    });
  }

  Future<List<EventCircle>> eventCircles(String eventId) async => [
    for (final r in _rows(
      await _rpc('get_my_event_circles', {'p_event': eventId}),
    ))
      if (r['id'] is String && r['name'] is String)
        EventCircle(
          r['id'] as String,
          r['name'] as String,
          (r['member_count'] as num?)?.toInt() ?? 0,
        ),
  ];

  static Event? _event(Map<String, dynamic> r) {
    try {
      return EventModel.fromJson(r).toEntity();
    } catch (_) {
      return null;
    }
  }
}
