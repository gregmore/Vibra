import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Consent guarantees of the circles migration (docs/circles.md).
void main() {
  final sql = File(
    'supabase/migrations/20261112000000_circles.sql',
  ).readAsStringSync();

  String body(String function) {
    final start = sql.indexOf('FUNCTION $function(');
    expect(start, isNonNegative, reason: '$function not found');
    return sql.substring(start, sql.indexOf(r'$$;', start));
  }

  test('only two paths create membership: creating, or accepting', () {
    final inserts = RegExp(r'INSERT INTO public\.circle_members')
        .allMatches(sql)
        .map((m) {
          final fn = sql.lastIndexOf('FUNCTION ', m.start);
          return sql.substring(fn + 9, sql.indexOf('(', fn));
        })
        .toSet();
    expect(inserts, {
      'public.create_circle',
      'public.respond_circle_invitation',
    });
    // create_circle adds only the caller (as admin).
    expect(
      body('public.create_circle'),
      contains("VALUES (v_id, v_me, 'admin')"),
    );
    // Accepting adds only the invitee, and only their own pending invitation.
    final respond = body('public.respond_circle_invitation');
    expect(respond, contains('invitee_id = v_me'));
    expect(respond, contains("v_inv.status <> 'pending'"));
    expect(respond, contains('VALUES (v_inv.circle_id, v_me)'));
  });

  test(
    'invitations need a relationship, respect blocks, declines and limits',
    () {
      final invite = body('public.invite_to_circle');
      expect(invite, contains('may_invite_to_circle(v_me, p_user)'));
      expect(invite, contains("consume_action_limit('circle-invite')"));
      expect(invite, contains('circle_invite_declined_recently'));
      expect(invite, contains('circle_full'));
      final may = body('vibra_private.may_invite_to_circle');
      expect(may, contains('may_access_message(p_inviter, p_invitee)'));
      expect(may, contains("f.status = 'accepted'"));
      expect(may, contains('may_access_music_match'));
    },
  );

  test('content is members-only and clients cannot write directly', () {
    expect(
      sql,
      contains(
        'GRANT SELECT ON public.circles, public.circle_members, public.circle_invitations, public.circle_messages,',
      ),
    );
    expect(sql, isNot(contains('GRANT INSERT')));
    final messages = sql.substring(
      sql.indexOf('CREATE POLICY circle_messages_read'),
      sql.indexOf('ALTER TABLE public.circle_playlist_items'),
    );
    expect(messages, contains('is_circle_member(circle_id)'));
    expect(
      messages,
      contains('may_access_message((SELECT auth.uid()), sender_id)'),
    );
  });

  test('invitations and messages notify through the existing worker', () {
    expect(sql, contains('circle_invitations_notify AFTER INSERT'));
    expect(sql, contains('circle_messages_notify AFTER INSERT'));
    expect(sql, contains("'circle_invite', 'circle_message'"));
    final worker = File(
      'supabase/functions/send-social-notification/index.ts',
    ).readAsStringSync();
    expect(worker, contains('.eq("muted", false)'));
    expect(worker, contains('blockedWithSender'));
  });
}
