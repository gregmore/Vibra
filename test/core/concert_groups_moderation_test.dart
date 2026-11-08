import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Moderation and membership guarantees of concert groups (docs/concert-groups.md).
void main() {
  final circles = File(
    'supabase/migrations/20261112000000_circles.sql',
  ).readAsStringSync();
  final plans = File(
    'supabase/migrations/20261115000000_concert_match.sql',
  ).readAsStringSync();

  String body(String sql, String fn) {
    final start = sql.indexOf('FUNCTION $fn(');
    expect(start, isNonNegative, reason: fn);
    return sql.substring(start, sql.indexOf(r'$$;', start));
  }

  test('banned people cannot be invited or accept an old invitation', () {
    expect(
      body(circles, 'public.invite_to_circle'),
      contains("'circle_banned'"),
    );
    expect(
      body(circles, 'public.respond_circle_invitation'),
      contains(
        'FROM public.circle_bans WHERE circle_id = v_inv.circle_id AND user_id = v_me',
      ),
    );
    final manage = body(circles, 'public.manage_circle_member');
    expect(manage, contains("WHEN 'ban' THEN"));
    expect(manage, contains('require_circle_role(p_circle, true)'));
  });

  test('messages: own delete, admin removal, held after two reports', () {
    expect(
      body(circles, 'public.remove_circle_message'),
      contains(
        'require_circle_role(v_msg.circle_id, v_msg.sender_id <> auth.uid())',
      ),
    );
    expect(
      body(circles, 'public.restore_circle_message'),
      contains('require_circle_role(v_circle, true)'),
    );
    expect(
      body(circles, 'vibra_private.hold_reported_circle_message'),
      contains('>= 2'),
    );
    final policy = circles.substring(
      circles.indexOf('CREATE POLICY circle_messages_read'),
      circles.indexOf('ALTER TABLE public.circle_bans ENABLE'),
    );
    expect(policy, contains('removed_at IS NULL'));
    expect(policy, contains('NOT held_for_review OR sender_id'));
  });

  test('reports must point at visible messages or co-members', () {
    final report = body(circles, 'public.protect_report_submission');
    expect(report, contains('Only visible circle messages may be reported'));
    expect(report, contains('Only members of your circles may be reported'));
    // Earlier rules are kept.
    expect(report, contains('Only received messages may be reported'));
    expect(report, contains('Only visible posts may be reported'));
  });

  test('participation status is members-only; plans notify members', () {
    expect(
      body(circles, 'public.set_circle_event_status'),
      contains('require_circle_role(p_circle, false)'),
    );
    expect(plans, contains('circle_plans_notify AFTER INSERT'));
    final worker = File(
      'supabase/functions/send-social-notification/index.ts',
    ).readAsStringSync();
    expect(worker, contains('payload.table === "circle_plans"'));
  });
}
