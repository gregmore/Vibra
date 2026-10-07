import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;

import '../../core/constants/db_tables.dart';
import '../../core/errors/exceptions.dart';
import '../../domain/entities/conversation_summary.dart';
import '../../domain/entities/follow_stats.dart';
import '../models/friendship_model.dart';
import '../models/message_model.dart';
import 'supabase_datasource.dart';

/// Datasource Supabase per social: amicizie e messaggi diretti.
class SupabaseSocialDatasource {
  SupabaseSocialDatasource(this._supabase);

  final SupabaseDatasource _supabase;

  Future<FriendshipModel> requestFriendship({
    required String receiverId,
  }) async {
    final user = _supabase.currentUser;
    if (user == null) {
      throw const AuthException(message: 'Utente non autenticato');
    }

    try {
      final row = await _supabase.insert(DbTables.friendships, {
        'requester_id': user.id,
        'receiver_id': receiverId,
        'status': 'pending',
      });
      return FriendshipModel.fromJson(row);
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        throw const ServerException(
          message: 'Richiesta di amicizia già inviata o già siete amici.',
        );
      }
      throw ServerException(
        message: 'Errore durante la richiesta di amicizia: ${e.message}',
      );
    } catch (e) {
      throw ServerException(
        message: 'Errore generico durante la richiesta di amicizia.',
      );
    }
  }

  Future<FriendshipModel> respondFriendship({
    required String friendshipId,
    required String status, // accepted|rejected
  }) async {
    final user = _supabase.currentUser;
    if (user == null) {
      throw const AuthException(message: 'Utente non autenticato');
    }

    final row = await _supabase.update(
      DbTables.friendships,
      {'status': status},
      matchColumn: 'id',
      matchValue: friendshipId,
    );
    return FriendshipModel.fromJson(row);
  }

  Future<void> deleteFriendship({required String friendshipId}) async {
    final user = _supabase.currentUser;
    if (user == null) {
      throw const AuthException(message: 'Utente non autenticato');
    }

    await _supabase.delete(
      DbTables.friendships,
      matchColumn: 'id',
      matchValue: friendshipId,
    );
  }

  Future<void> cancelFriendRequest({required String friendshipId}) async {
    await deleteFriendship(friendshipId: friendshipId);
  }

  Future<List<FriendshipModel>> listMyFriendships({String? status}) async {
    final user = _supabase.currentUser;
    if (user == null) {
      throw const AuthException(message: 'Utente non autenticato');
    }

    try {
      var query = _supabase.client
          .from(DbTables.friendships)
          .select()
          .or('requester_id.eq.${user.id},receiver_id.eq.${user.id}');

      if (status != null) {
        query = query.eq('status', status);
      }

      final rows = await query.order('created_at', ascending: false).limit(200);
      return List<Map<String, dynamic>>.from(
        rows,
      ).map(FriendshipModel.fromJson).toList(growable: false);
    } catch (e) {
      throw ServerException(
        message: 'Errore nel caricamento amicizie',
        endpoint: DbTables.friendships,
      );
    }
  }

  Future<MessageModel> sendMessage({
    required String receiverId,
    required String content,
    String messageType = 'text',
    Map<String, dynamic>? metadata,
  }) async {
    final user = _supabase.currentUser;
    if (user == null) {
      throw const AuthException(message: 'Utente non autenticato');
    }

    final row = await _supabase.insert(DbTables.messages, {
      'sender_id': user.id,
      'receiver_id': receiverId,
      'content': content,
      'message_type': messageType,
      'metadata': ?metadata,
    });
    return MessageModel.fromJson(row);
  }

  Future<void> blockUser({required String blockedId}) async {
    final user = _supabase.currentUser;
    if (user == null) {
      throw const AuthException(message: 'Utente non autenticato');
    }
    await _supabase.insert('blocked_users', {
      'blocker_id': user.id,
      'blocked_id': blockedId,
    });
  }

  Future<void> reportUser({
    required String reportedId,
    required String reason,
    String? description,
    String? messageId,
  }) async {
    final user = _supabase.currentUser;
    if (user == null) {
      throw const AuthException(message: 'Utente non autenticato');
    }
    await _supabase.insert('reports', {
      'reporter_id': user.id,
      'reported_id': reportedId,
      'reason': reason,
      'description': ?description,
      'message_id': ?messageId,
    });
  }

  Future<void> softDeleteChat({required String otherUserId}) async {
    final user = _supabase.currentUser;
    if (user == null) {
      throw const AuthException(message: 'Utente non autenticato');
    }

    // We append our user ID to deleted_by array for messages between us and the other user
    // The query finds messages where sender is A and receiver is B, or vice-versa
    await _supabase.client.rpc(
      'soft_delete_chat',
      params: {'p_user_id': user.id, 'p_other_user_id': otherUserId},
    );
  }

  Future<void> reactToMessage({
    required String messageId,
    required String reaction,
  }) async {
    final user = _supabase.currentUser;
    if (user == null) {
      throw const AuthException(message: 'Utente non autenticato');
    }

    // Using an RPC to update jsonb is better, or doing a select then update
    await _supabase.client.rpc(
      'react_to_message',
      params: {
        'p_message_id': messageId,
        'p_user_id': user.id,
        'p_reaction': reaction,
      },
    );
  }

  Future<List<MessageModel>> listMessagesWith({
    required String otherUserId,
    int limit = 50,
  }) async {
    final user = _supabase.currentUser;
    if (user == null) {
      throw const AuthException(message: 'Utente non autenticato');
    }

    try {
      final rows = await _supabase.client
          .from(DbTables.messages)
          .select()
          .or(
            'and(sender_id.eq.${user.id},receiver_id.eq.$otherUserId),and(sender_id.eq.$otherUserId,receiver_id.eq.${user.id})',
          )
          .order('created_at', ascending: true)
          .limit(limit);

      return List<Map<String, dynamic>>.from(
        rows,
      ).map(MessageModel.fromJson).toList(growable: false);
    } catch (e) {
      throw ServerException(
        message: 'Errore nel caricamento messaggi',
        endpoint: DbTables.messages,
      );
    }
  }

  Future<List<Map<String, dynamic>>> listMyMatches({int limit = 20}) async {
    final user = _supabase.currentUser;
    if (user == null) {
      throw const AuthException(message: 'Utente non autenticato');
    }

    try {
      final rows = await _supabase.client
          .from(DbTables.userMatches)
          .select()
          .or('user_id_a.eq.${user.id},user_id_b.eq.${user.id}')
          .order('compatibility', ascending: false)
          .limit(limit);

      return List<Map<String, dynamic>>.from(rows);
    } catch (e) {
      throw ServerException(
        message: 'Errore nel caricamento match utenti',
        endpoint: DbTables.userMatches,
      );
    }
  }

  Future<List<Map<String, dynamic>>> getPublicUsersByIds(
    List<String> ids,
  ) async {
    if (ids.isEmpty) return const [];

    try {
      final rows = await _supabase.client
          .from(DbTables.usersPublic)
          .select()
          .inFilter('id', ids);
      return List<Map<String, dynamic>>.from(rows);
    } catch (e) {
      throw ServerException(
        message: 'Errore nel caricamento profili pubblici',
        endpoint: DbTables.usersPublic,
      );
    }
  }

  Stream<List<MessageModel>> streamMessagesWith({required String otherUserId}) {
    final user = _supabase.currentUser;
    if (user == null) {
      throw const AuthException(message: 'Utente non autenticato');
    }

    final stream = _supabase.client
        .from(DbTables.messages)
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .limit(200);

    return stream.map(
      (rows) => rows
          .map(MessageModel.fromJson)
          .where(
            (m) =>
                (m.senderId == user.id && m.receiverId == otherUserId) ||
                (m.senderId == otherUserId && m.receiverId == user.id),
          )
          .toList(growable: false),
    );
  }

  Future<void> markMessagesAsRead({required String otherUserId}) async {
    final user = _supabase.currentUser;
    if (user == null) return;

    try {
      await _supabase.client
          .from(DbTables.messages)
          .update({'read_at': DateTime.now().toIso8601String()})
          .eq('sender_id', otherUserId)
          .eq('receiver_id', user.id)
          .filter('read_at', 'is', null);
    } catch (_) {
      // Ignora errori di background mark as read
    }
  }

  /// Recupera i profili musicali (top_artists, top_genres) per un set di user IDs.
  /// Usato per arricchire le card match con artisti e generi condivisi.
  Future<List<Map<String, dynamic>>> getMusicProfilesByUserIds(
    List<String> userIds,
  ) async {
    if (userIds.isEmpty) return const [];

    try {
      final rows = await _supabase.client
          .from(DbTables.musicProfilesPublic)
          .select('user_id, top_artists, top_genres')
          .inFilter('user_id', userIds);
      return List<Map<String, dynamic>>.from(rows);
    } catch (e) {
      // Non critico: se fallisce, la card mostrerà semplicemente meno dettagli
      return const [];
    }
  }

  Future<List<ConversationSummary>> listConversations() async {
    final user = _supabase.currentUser;
    if (user == null) {
      throw const AuthException(message: 'Utente non autenticato');
    }

    try {
      final rows = await _supabase.client.rpc('get_user_conversations');
      return (rows as List<dynamic>)
          .map((row) {
            final r = row as Map<String, dynamic>;
            return ConversationSummary(
              otherUserId: r['other_user_id']?.toString() ?? '',
              otherUsername: r['other_username']?.toString() ?? 'user',
              otherDisplayName: r['other_display_name']?.toString(),
              otherAvatarUrl: r['other_avatar_url']?.toString(),
              lastMessageContent: r['last_message_content']?.toString() ?? '',
              lastMessageCreatedAt: r['last_message_created_at'] != null
                  ? DateTime.parse(r['last_message_created_at'].toString())
                  : DateTime.now(),
              lastMessageSenderId: r['last_message_sender_id']?.toString(),
              unreadCount: (r['unread_count'] as num?)?.toInt() ?? 0,
              isFriend: r['is_friend'] == true,
              isMessageRequest: r['is_message_request'] == true,
            );
          })
          .toList(growable: false);
    } catch (e) {
      throw ServerException(
        message: 'Errore nel caricamento conversazioni',
        endpoint: 'get_user_conversations',
      );
    }
  }

  Future<void> followUser({required String userId}) async {
    final user = _supabase.currentUser;
    if (user == null) {
      throw const AuthException(message: 'Utente non autenticato');
    }

    try {
      await _supabase.client.from(DbTables.follows).insert({
        'follower_id': user.id,
        'following_id': userId,
      });
    } catch (_) {
      // Ignora errori (es. utente già seguito) per evitare crash nella UI
    }
  }

  Future<void> unfollowUser({required String userId}) async {
    final user = _supabase.currentUser;
    if (user == null) {
      throw const AuthException(message: 'Utente non autenticato');
    }

    try {
      await _supabase.client
          .from(DbTables.follows)
          .delete()
          .eq('follower_id', user.id)
          .eq('following_id', userId);
    } catch (_) {
      // Ignora errori
    }
  }

  Future<FollowStats> getFollowStats({required String userId}) async {
    try {
      final rows = await _supabase.client.rpc(
        'get_user_follow_stats',
        params: {'p_user_id': userId},
      );

      if (rows is List && rows.isNotEmpty) {
        final r = rows.first as Map<String, dynamic>;
        return FollowStats(
          followersCount: (r['followers_count'] as num?)?.toInt() ?? 0,
          followingCount: (r['following_count'] as num?)?.toInt() ?? 0,
          isFollowing: r['is_following'] == true,
          isFollower: r['is_follower'] == true,
        );
      }
      return const FollowStats.empty();
    } catch (e) {
      return const FollowStats.empty();
    }
  }

  Future<List<Map<String, dynamic>>> getFollowers({
    required String userId,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final rows = await _supabase.client.rpc(
        'get_user_followers',
        params: {'p_user_id': userId, 'p_limit': limit, 'p_offset': offset},
      );
      return List<Map<String, dynamic>>.from(rows ?? []);
    } catch (e) {
      return const [];
    }
  }

  Future<List<Map<String, dynamic>>> getFollowing({
    required String userId,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final rows = await _supabase.client.rpc(
        'get_user_following',
        params: {'p_user_id': userId, 'p_limit': limit, 'p_offset': offset},
      );
      return List<Map<String, dynamic>>.from(rows ?? []);
    } catch (e) {
      return const [];
    }
  }
}
