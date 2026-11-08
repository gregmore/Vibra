import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Notification Center (docs/notification-center.md): one server-side
/// delivery policy for every worker.
void main() {
  final sql = File(
    'supabase/migrations/20261125000000_notification_center.sql',
  ).readAsStringSync();
  final policy = sql.substring(
    sql.indexOf('FUNCTION public.record_notification('),
    sql.indexOf(r'$$;', sql.indexOf('FUNCTION public.record_notification(')),
  );

  test('every requested kind maps to a category the user controls', () {
    for (final type in [
      'friend_request',
      'request_accepted',
      'chat_message',
      'community_comment',
      'circle_invite',
      'artist_concert',
      'event_reminder',
      'recommendation',
      'vibe_comment',
      'discovery',
    ]) {
      expect(sql, contains("'$type'"), reason: type);
    }
    expect(
      policy,
      contains("(v_user.push_settings->>v_category) IS DISTINCT FROM 'false'"),
    );
  });

  test('excessive notifications are prevented on the server', () {
    expect(policy, contains("interval '12 hours'")); // grouping window
    expect(policy, contains("interval '30 minutes'")); // no re-push of a group
    expect(policy, contains('v_pref.qs')); // quiet hours
    expect(policy, contains('v_pref.cap')); // daily cap
    expect(
      policy,
      contains(
        "IN ('communities', 'recommendations', 'discoveries', 'updates')",
      ),
    );
    expect(policy, contains("RETURN jsonb_build_object('skipped', 'blocked')"));
    expect(policy, contains("'Service role required'"));
  });

  test('no worker writes notifications or pushes outside the policy', () {
    for (final f in [
      'send-social-notification',
      'event-reminders',
      'send-notifications',
      'send-chat-notification',
      'retention-notifications',
    ]) {
      final src = File('supabase/functions/$f/index.ts').readAsStringSync();
      expect(src, isNot(contains('from("notifications").insert')), reason: f);
      expect(src, isNot(contains("from('notifications').insert")), reason: f);
      expect(
        src.contains('deliver(') || src.contains('"record_notification"'),
        isTrue,
        reason: f,
      );
    }
    // Push only through the configured FCM provider.
    final delivery = File(
      'supabase/functions/_shared/notification_delivery.ts',
    ).readAsStringSync();
    expect(delivery, contains('import { sendFcm } from "./fcm.ts"'));
  });

  test(
    'new sources: accepted requests, communities, discoveries, recommendations',
    () {
      expect(sql, contains('CREATE TRIGGER friendships_accepted_notify'));
      expect(sql, contains('CREATE TRIGGER community_comments_notify'));
      expect(sql, contains('CREATE TRIGGER discovery_collection_notify'));
      expect(
        sql,
        contains(
          "NEW.kind IN ('recommendation', 'discovery') AND NEW.visibility = 'everyone'",
        ),
      );
      expect(
        sql,
        contains('NOT vibra_private.blocked_between(p_author, f.follower_id)'),
      );
    },
  );
}
