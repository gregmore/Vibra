import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Privacy, moderation and licensing guarantees of Music Stories
/// (docs/music-stories.md), checked against the migration and functions.
void main() {
  final sql = File(
    'supabase/migrations/20261117000000_music_stories.sql',
  ).readAsStringSync();
  final fn = File(
    'supabase/functions/music-stories/index.ts',
  ).readAsStringSync();
  final shared = File(
    'supabase/functions/_shared/music_stories.ts',
  ).readAsStringSync();
  final upload = File(
    'supabase/functions/upload-image/index.ts',
  ).readAsStringSync();

  String section(String from, String to) =>
      sql.substring(sql.indexOf(from), sql.indexOf(to, sql.indexOf(from)));

  test('every story expires within 24 hours and every read checks it', () {
    expect(
      sql,
      contains(
        "expires_at timestamptz NOT NULL DEFAULT now() + interval '24 hours'",
      ),
    );
    expect(
      sql,
      contains("CHECK (expires_at <= created_at + interval '24 hours')"),
    );
    final can = section('FUNCTION public.can_see_music_story(', r'$$;');
    expect(can, contains('p_expires > now()'));
    expect(sql, contains("cron.schedule('purge-expired-music-stories'"));
    // Photos of expired or deleted stories are deleted by the worker.
    expect(sql, contains("cron.schedule('invoke-media-purge'"));
    expect(
      File('supabase/functions/media-purge/index.ts').readAsStringSync(),
      contains('catalogueJobAuthorized'),
    );
  });

  test('visibility reuses the audience, blocks and the hidden list', () {
    final can = section('FUNCTION public.can_see_music_story(', r'$$;');
    expect(can, contains('public.can_see_daily_vibe('));
    expect(can, contains('story_hidden_viewers'));
    expect(
      sql,
      contains(
        'USING (public.can_see_music_story(user_id, visibility, expires_at, held_for_review))',
      ),
    );
    // DEFINER writes re-check visibility.
    for (final f in [
      'mark_music_story_viewed',
      'toggle_music_story_reaction',
      'send_music_story_reply',
    ]) {
      expect(
        section('FUNCTION public.$f(', r'$$;'),
        contains('require_visible_story(p_story)'),
        reason: f,
      );
    }
  });

  test('views are visible to the author only; replies to the two people', () {
    expect(
      section('CREATE POLICY music_story_views_read', ';'),
      contains('s.user_id = (SELECT auth.uid())'),
    );
    final viewers = section('FUNCTION public.get_music_story_viewers(', r'$$;');
    expect(viewers, contains('s.user_id = auth.uid()'));
    expect(viewers, contains('may_access_message'));
    final replies = section('CREATE POLICY music_story_replies_read', ';');
    expect(replies, contains('sender_id = (SELECT auth.uid())'));
    expect(replies, contains('recipient_id = (SELECT auth.uid())'));
    // The author can only answer a viewer who replied first.
    final send = section('FUNCTION public.send_music_story_reply(', r'$$;');
    expect(
      send,
      contains('r.sender_id = p_recipient AND r.recipient_id = auth.uid()'),
    );
    expect(send, contains("'replies_off'"));
  });

  test('photos: private bucket, backend-only writes, metadata stripped', () {
    expect(sql, contains("VALUES ('story-media', 'story-media', false"));
    for (final op in ['INSERT', 'UPDATE', 'DELETE']) {
      expect(sql, contains("AS RESTRICTIVE FOR $op TO authenticated"));
    }
    expect(
      section('CREATE POLICY story_media_select_visible', ';'),
      contains('public.music_stories s'),
    );
    expect(upload, contains('"story-media"'));
    expect(upload, contains('Re-encoding removes metadata'));
    // A post may only use the caller's own upload.
    expect(shared, contains(r'body.media_path.startsWith(`${userId}/`)'));
    expect(
      section('FUNCTION public.create_music_story(', r'$$;'),
      contains("split_part(o.name, '/', 1) = p_user_id::text"),
    );
  });

  test('music metadata comes from Spotify; no audio, artwork not copied', () {
    expect(fn, contains(r'spotify(`/${type}s/${body.item_id}`)'));
    expect(
      section('FUNCTION public.create_music_story(', r'$$;'),
      contains("'Service role required'"),
    );
    final table = section(
      'CREATE TABLE public.music_stories',
      'CREATE INDEX music_stories_author_idx',
    );
    for (final audio in ['preview', 'audio', 'mp3', 'stream_url']) {
      expect(table, isNot(contains(audio)));
      expect(fn, isNot(contains(audio)));
      expect(shared, isNot(contains('$audio:')));
    }
    expect(
      table,
      contains(r"artwork_url ~ '^https://(i\.scdn\.co|mosaic\.scdn\.co"),
    );
  });

  test('reports, holds, rate limits and notifications', () {
    final protect = section(
      'FUNCTION public.protect_report_submission()',
      r'$$;',
    );
    expect(protect, contains('NEW.music_story_id'));
    expect(protect, contains('r.recipient_id=auth.uid()'));
    final hold = section(
      'FUNCTION vibra_private.hold_reported_music_story()',
      r'$$;',
    );
    expect(hold, contains('>= 3'));
    for (final a in [
      'story-reaction',
      'story-reply',
      'story-view',
      'story-settings',
    ]) {
      expect(sql, contains("WHEN '$a'"));
    }
    expect(sql, contains("'story_rate_limit'"));
    expect(sql, contains("'story_reply'"));
    expect(sql, contains('music_story_replies_notify'));
    expect(sql, contains("'music_stories', COALESCE("));
  });
}
