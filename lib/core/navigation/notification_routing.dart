import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/mappers/domain_mappers.dart';
import '../../data/models/event_model.dart';
import '../utils/logger.dart';

/// Where a notification leads (docs/notification-center.md). Used by push
/// taps and by the notification center, so both open the same place.
void openNotificationTarget(
  BuildContext context,
  String? type,
  Map<String, dynamic> data, {
  String? senderName,
}) {
  if (!context.mounted) return;
  String? s(String key) {
    final v = data[key];
    return v == null || '$v'.isEmpty ? null : '$v';
  }

  switch (type) {
    case 'chat_message':
    case 'message_request':
      final senderId = s('sender_id');
      if (senderId != null) {
        context.push(
          '/chat',
          extra: {
            'otherUserId': senderId,
            'otherDisplayName': senderName ?? 'Chat',
          },
        );
      }
    case 'friend_request':
      context.push('/friends');
    case 'request_accepted':
      final senderId = s('sender_id');
      senderId == null
          ? context.push('/friends')
          : context.push('/user-profile', extra: senderId);
    case 'vibe_comment':
      context.push('/daily-vibe');
    case 'feed_comment':
    case 'recommendation':
      final postId = s('post_id');
      context.push(postId == null ? '/feed' : '/feed-post', extra: postId);
    case 'story_reply':
      final owner = s('story_owner_id');
      if (owner != null) {
        context.push(
          '/stories',
          extra: {'user': owner, 'story': s('story_id')},
        );
      }
    case 'community_comment':
    case 'community_reply':
      final communityId = s('community_id');
      context.push(
        communityId == null ? '/communities' : '/community',
        extra: communityId,
      );
    case 'circle_invite':
      context.push('/circles');
    case 'circle_message':
    case 'circle_plan':
      final circleId = s('circle_id');
      context.push(circleId == null ? '/circles' : '/circle', extra: circleId);
    case 'match':
      context.push('/social');
    case 'discovery':
      context.push('/discoveries');
    case 'live_chat':
      final eventId = s('event_id');
      context.push(
        Uri(
          path: '/live',
          queryParameters: eventId == null ? null : {'eventId': eventId},
        ).toString(),
      );
    case 'event_alert':
    case 'artist_concert':
    case 'event_update':
    case 'event_reminder':
    case 'ticket_low':
    case 'retention':
    case 'digest':
      final eventId = s('event_id');
      if (eventId != null) unawaited(_openEvent(eventId, context));
  }
}

Future<void> _openEvent(String eventId, BuildContext context) async {
  try {
    final row = await Supabase.instance.client
        .from('events')
        .select()
        .eq('id', eventId)
        .maybeSingle();
    if (!context.mounted) return;
    if (row != null) {
      unawaited(
        context.push(
          '/event-detail',
          extra: EventModel.fromJson(row).toEntity(),
        ),
      );
      return;
    }
  } catch (_) {
    VibraLogger.warning('Evento della notifica non disponibile', tag: 'Push');
  }
  if (context.mounted) unawaited(context.push('/explore'));
}
