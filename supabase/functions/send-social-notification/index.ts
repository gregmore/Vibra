import { corsHeaders, handleOptions } from "../_shared/cors.ts";
import { createSupabaseServiceClient } from "../_shared/supabase.ts";
import { deliver } from "../_shared/notification_delivery.ts";
import { notificationWorkerAuthorized } from "../_shared/notification_worker_auth.ts";
import { skipDisabledSpotifyJob } from "../_shared/spotify-feature.ts";

type WebhookPayload = {
  type: "INSERT" | "UPDATE" | "DELETE";
  table: string;
  record: Record<string, unknown>;
  schema: string;
};

type Recipient = {
  userId: string;
  actorId: string;
  kind: "message" | "friendship" | "match" | "circle_invite" | "circle_message" | "circle_plan" | "vibe_comment" | "story_reply" | "feed_comment" | "accepted" |
    "community_comment" | "discovery" | "recommendation";
  vibeId?: string;
  isReply?: boolean;
  circleId?: string;
  circleName?: string;
  storyId?: string;
  storyOwnerId?: string;
  postId?: string;
  communityId?: string;
  communityPostId?: string;
  title?: string;
};

async function usersAreFriends(
  supabase: ReturnType<typeof createSupabaseServiceClient>,
  firstUserId: string,
  secondUserId: string,
) {
  const { data, error } = await supabase
    .from("friendships")
    .select("id")
    .eq("status", "accepted")
    .or(
      `and(requester_id.eq.${firstUserId},receiver_id.eq.${secondUserId}),and(requester_id.eq.${secondUserId},receiver_id.eq.${firstUserId})`,
    )
    .limit(1);

  if (error) throw error;
  return (data?.length ?? 0) > 0;
}

Deno.serve(async (req) => {
  const preflight = handleOptions(req);
  if (preflight) return preflight;

  if (!await notificationWorkerAuthorized(req)) {
    return new Response(JSON.stringify({ error: "Unauthorized" }), {
      status: 401,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }

  if (req.method.toUpperCase() !== "POST") {
    return new Response(JSON.stringify({ error: "Method not allowed" }), {
      status: 405,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }

  try {
    const payload = (await req.json()) as WebhookPayload;
    const accepted = payload.type === "UPDATE" && payload.table === "friendships" &&
      payload.record?.status === "accepted";
    if (payload.type !== "INSERT" && !accepted) {
      return new Response(JSON.stringify({ ok: true, ignored: true }), {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // Friendship and chat delivery remain operational while musical affinities
    // are paused. Ignore only the music-derived webhook before reading users.
    if (payload.table === "user_matches") {
      const paused = skipDisabledSpotifyJob();
      if (paused) return paused;
    }
    const record = payload.record;
    const supabase = createSupabaseServiceClient();
    const recipients: Recipient[] = [];

    if (payload.table === "messages") {
      const receiverId = String(record.receiver_id ?? "");
      const senderId = String(record.sender_id ?? "");
      if (receiverId && senderId) {
        recipients.push({ userId: receiverId, actorId: senderId, kind: "message" });
      }
    } else if (payload.table === "friendships") {
      const receiverId = String(record.receiver_id ?? "");
      const requesterId = String(record.requester_id ?? "");
      if (receiverId && requesterId) {
        recipients.push(accepted
          // The request was accepted: tell the person who sent it.
          ? { userId: requesterId, actorId: receiverId, kind: "accepted" }
          : { userId: receiverId, actorId: requesterId, kind: "friendship" });
      }
    } else if (payload.table === "user_matches") {
      const firstUserId = String(record.user_id_a ?? "");
      const secondUserId = String(record.user_id_b ?? "");
      if (firstUserId && secondUserId) {
        // A new match is meaningful to both people, not just the row's second ID.
        recipients.push(
          { userId: firstUserId, actorId: secondUserId, kind: "match" },
          { userId: secondUserId, actorId: firstUserId, kind: "match" },
        );
      }
    } else if (
      payload.table === "circle_invitations" || payload.table === "circle_messages" ||
      payload.table === "circle_plans"
    ) {
      // Circles (docs/circles.md): invitations go to the invitee only; a
      // message goes to every other member who has not muted the circle.
      const circleId = String(record.circle_id ?? "");
      const { data: circle, error: circleError } = await supabase
        .from("circles").select("name, archived_at").eq("id", circleId).maybeSingle();
      if (circleError) throw circleError;
      if (circle && !circle.archived_at) {
        if (payload.table === "circle_invitations") {
          const inviteeId = String(record.invitee_id ?? "");
          const inviterId = String(record.inviter_id ?? "");
          if (inviteeId && inviterId && record.status === "pending") {
            recipients.push({
              userId: inviteeId, actorId: inviterId, kind: "circle_invite", circleId, circleName: circle.name,
            });
          }
        } else {
          // Messages and new plans go to the other unmuted members.
          const senderId = String(record.sender_id ?? record.created_by ?? "");
          const kind = payload.table === "circle_plans" ? "circle_plan" : "circle_message";
          const { data: members, error: membersError } = await supabase
            .from("circle_members").select("user_id").eq("circle_id", circleId).eq("muted", false);
          if (membersError) throw membersError;
          // Members who blocked the sender, or were blocked by them, are not
          // notified (their chat view hides those messages too).
          const { data: blocks, error: blocksError } = await supabase
            .from("blocked_users").select("blocker_id, blocked_id")
            .or(`blocker_id.eq.${senderId},blocked_id.eq.${senderId}`);
          if (blocksError) throw blocksError;
          const blockedWithSender = new Set(
            (blocks ?? []).map((b: { blocker_id: string; blocked_id: string }) =>
              b.blocker_id === senderId ? b.blocked_id : b.blocker_id),
          );
          for (const member of members ?? []) {
            const userId = String(member.user_id);
            if (userId === senderId || blockedWithSender.has(userId)) continue;
            recipients.push({ userId, actorId: senderId, kind, circleId, circleName: circle.name });
          }
        }
      }
    } else if (payload.table === "daily_vibe_comments") {
      // Daily Vibe (docs/daily-vibe.md): the vibe's owner, and the author of
      // the comment being replied to, are notified (never the commenter).
      const authorId = String(record.author_id ?? "");
      const vibeId = String(record.vibe_id ?? "");
      const { data: vibe } = await supabase.from("daily_vibes").select("user_id").eq("id", vibeId).maybeSingle();
      const targets = new Map<string, boolean>();
      if (vibe?.user_id) targets.set(String(vibe.user_id), false);
      if (record.parent_id) {
        const { data: parent } = await supabase.from("daily_vibe_comments")
          .select("author_id").eq("id", String(record.parent_id)).maybeSingle();
        if (parent?.author_id) targets.set(String(parent.author_id), true);
      }
      const { data: blocks } = await supabase.from("blocked_users").select("blocker_id, blocked_id")
        .or(`blocker_id.eq.${authorId},blocked_id.eq.${authorId}`);
      const blocked = new Set((blocks ?? []).map((b: { blocker_id: string; blocked_id: string }) =>
        b.blocker_id === authorId ? b.blocked_id : b.blocker_id));
      for (const [userId, isReply] of targets) {
        if (userId === authorId || blocked.has(userId)) continue;
        recipients.push({ userId, actorId: authorId, kind: "vibe_comment", vibeId, isReply });
      }
    } else if (payload.table === "feed_comments") {
      // VIBRA Feed (docs/vibra-feed.md): the post's author, and the author of
      // the comment being replied to (never the commenter, never blocked).
      const authorId = String(record.author_id ?? "");
      const postId = String(record.post_id ?? "");
      const { data: post } = await supabase.from("feed_posts").select("user_id").eq("id", postId).maybeSingle();
      const targets = new Map<string, boolean>();
      if (post?.user_id) targets.set(String(post.user_id), false);
      if (record.parent_id) {
        const { data: parent } = await supabase.from("feed_comments")
          .select("author_id").eq("id", String(record.parent_id)).maybeSingle();
        if (parent?.author_id) targets.set(String(parent.author_id), true);
      }
      const { data: blocks } = await supabase.from("blocked_users").select("blocker_id, blocked_id")
        .or(`blocker_id.eq.${authorId},blocked_id.eq.${authorId}`);
      const blocked = new Set((blocks ?? []).map((b: { blocker_id: string; blocked_id: string }) =>
        b.blocker_id === authorId ? b.blocked_id : b.blocker_id));
      for (const [userId, isReply] of targets) {
        if (userId === authorId || blocked.has(userId)) continue;
        recipients.push({ userId, actorId: authorId, kind: "feed_comment", postId, isReply });
      }
    } else if (payload.table === "community_comments") {
      // Communities: the post's author hears about a new comment.
      const authorId = String(record.author_id ?? "");
      const postId = String(record.post_id ?? "");
      const { data: post } = await supabase.from("community_posts")
        .select("author_id, community_id, title, removed_at").eq("id", postId).maybeSingle();
      if (post?.author_id && !post.removed_at && String(post.author_id) !== authorId) {
        const { data: community } = await supabase.from("communities")
          .select("name").eq("id", post.community_id).maybeSingle();
        recipients.push({
          userId: String(post.author_id), actorId: authorId, kind: "community_comment",
          communityId: String(post.community_id), communityPostId: postId, title: community?.name ?? undefined,
        });
      }
    } else if (payload.table === "discovery_collection") {
      // Someone saved a song you shared (grouped per day).
      const saverId = String(record.user_id ?? "");
      const sharerId = String(record.found_via ?? "");
      if (saverId && sharerId && saverId !== sharerId) {
        recipients.push({ userId: sharerId, actorId: saverId, kind: "discovery", title: String(record.title ?? "") });
      }
    } else if (payload.table === "feed_posts") {
      // A public recommendation from someone you follow (grouped per day).
      const authorId = String(record.user_id ?? "");
      const { data: audience, error: audienceError } = await supabase
        .rpc("get_recommendation_audience", { p_author: authorId, p_limit: 300 });
      if (audienceError) throw audienceError;
      for (const row of (audience ?? []) as { user_id: string }[]) {
        recipients.push({
          userId: String(row.user_id), actorId: authorId, kind: "recommendation",
          postId: String(record.id ?? ""), title: String(record.title ?? ""),
        });
      }
    } else if (payload.table === "music_story_replies") {
      // Music Stories (docs/music-stories.md): a private reply goes to its
      // recipient only (the author, or the viewer who started the thread).
      const senderId = String(record.sender_id ?? "");
      const recipientId = String(record.recipient_id ?? "");
      if (senderId && recipientId && senderId !== recipientId) {
        const { data: blocks } = await supabase.from("blocked_users").select("blocker_id")
          .or(`and(blocker_id.eq.${senderId},blocked_id.eq.${recipientId}),and(blocker_id.eq.${recipientId},blocked_id.eq.${senderId})`)
          .limit(1);
        const storyId = String(record.story_id ?? "");
        const { data: story } = await supabase.from("music_stories").select("user_id").eq("id", storyId).maybeSingle();
        if (!blocks?.length && story?.user_id) {
          recipients.push({
            userId: recipientId, actorId: senderId, kind: "story_reply",
            storyId, storyOwnerId: String(story.user_id),
          });
        }
      }
    } else {
      return new Response(JSON.stringify({ ok: true, skipped: "Table not supported" }), {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const uniqueRecipients = recipients.filter(
      (recipient, index) =>
        recipients.findIndex((candidate) => candidate.userId === recipient.userId) === index,
    );

    let inAppCreated = 0;
    let pushesSent = 0;
    const skipped: string[] = [];
    const day = new Date().toISOString().slice(0, 10);

    for (const recipient of uniqueRecipients) {
      const { data: actor, error: actorError } = await supabase
        .from("users").select("username, display_name").eq("id", recipient.actorId).maybeSingle();
      if (actorError) throw actorError;

      const actorName = actor?.display_name ?? actor?.username ?? "Un utente";
      let notificationType = "chat_message";
      let title = `Nuovo messaggio da ${actorName}`;
      let body = String(record.content ?? "").slice(0, 100);
      // Repeats of the same thing are grouped instead of stacked.
      let groupKey: string | null = null;

      if (recipient.kind === "message") {
        const isFriend = await usersAreFriends(supabase, recipient.userId, recipient.actorId);
        if (!isFriend) {
          notificationType = "message_request";
          title = `Nuova richiesta di messaggio da ${actorName}`;
        }
        groupKey = `chat:${recipient.actorId}`;
      } else if (recipient.kind === "friendship") {
        notificationType = "friend_request";
        title = "Nuova richiesta Vibra";
        body = `${actorName} ti ha inviato una richiesta di connessione.`;
      } else if (recipient.kind === "accepted") {
        notificationType = "request_accepted";
        title = "Richiesta accettata";
        body = `${actorName} ha accettato la tua richiesta. Ora siete collegati.`;
      } else if (recipient.kind === "circle_invite") {
        notificationType = "circle_invite";
        title = `Invito a ${recipient.circleName}`;
        body = `${actorName} ti ha invitato nel circle "${recipient.circleName}". Puoi accettare o rifiutare.`;
      } else if (recipient.kind === "circle_message") {
        notificationType = "circle_message";
        title = String(recipient.circleName ?? "Circle");
        body = `${actorName}: ${String(record.body ?? "").slice(0, 100)}`;
        groupKey = `circle:${recipient.circleId}`;
      } else if (recipient.kind === "circle_plan") {
        notificationType = "circle_plan";
        title = String(recipient.circleName ?? "Circle");
        body = `${actorName} ha proposto: ${String(record.title ?? "").slice(0, 80)}`;
      } else if (recipient.kind === "vibe_comment") {
        notificationType = "vibe_comment";
        title = recipient.isReply ? `${actorName} ti ha risposto` : `${actorName} ha commentato il tuo vibe`;
        body = String(record.body ?? "").slice(0, 100);
        groupKey = `vibe:${recipient.vibeId}`;
      } else if (recipient.kind === "feed_comment") {
        notificationType = "feed_comment";
        title = recipient.isReply ? `${actorName} ti ha risposto` : `${actorName} ha commentato il tuo post`;
        body = String(record.body ?? "").slice(0, 100);
        groupKey = `post:${recipient.postId}`;
      } else if (recipient.kind === "community_comment") {
        notificationType = "community_comment";
        title = recipient.title ? `Nuovo commento in ${recipient.title}` : "Nuovo commento";
        body = `${actorName}: ${String(record.body ?? "").slice(0, 100)}`;
        groupKey = `community-post:${recipient.communityPostId}`;
      } else if (recipient.kind === "discovery") {
        notificationType = "discovery";
        title = "Hai fatto scoprire un brano";
        body = `${actorName} ha salvato "${String(recipient.title ?? "").slice(0, 80)}" che hai condiviso.`;
        groupKey = `discovery:${day}`;
      } else if (recipient.kind === "recommendation") {
        notificationType = "recommendation";
        title = "Nuovi consigli musicali";
        body = `${actorName} consiglia "${String(recipient.title ?? "").slice(0, 80)}".`;
        groupKey = `recommendation:${day}`;
      } else if (recipient.kind === "story_reply") {
        notificationType = "story_reply";
        title = `${actorName} ha risposto alla tua storia`;
        body = String(record.body ?? "").slice(0, 100);
        groupKey = `story:${recipient.storyId}:${recipient.actorId}`;
      } else {
        notificationType = "match";
        title = "Nuova affinità trovata!";
        body = `Hai un'affinità del ${Math.round(Number(record.compatibility ?? 0))}% con ${actorName}.`;
      }

      // One policy for every notification (record_notification): grouping,
      // preferences, quiet hours, daily caps and blocks are decided there.
      const result = await deliver(supabase, {
        userId: recipient.userId,
        type: notificationType,
        title,
        body,
        actorId: recipient.actorId,
        groupKey,
        data: {
          sender_id: recipient.actorId,
          record_id: String(record.id ?? ""),
          ...(recipient.circleId ? { circle_id: recipient.circleId } : {}),
          ...(recipient.storyId ? { story_id: recipient.storyId, story_owner_id: String(recipient.storyOwnerId) } : {}),
          ...(recipient.postId ? { post_id: recipient.postId } : {}),
          ...(recipient.communityId ? { community_id: recipient.communityId, community_post_id: String(recipient.communityPostId) } : {}),
        },
      });
      if (!result.stored) {
        skipped.push(recipient.userId);
        continue;
      }
      inAppCreated++;
      if (result.pushed) pushesSent++;
    }

    return new Response(
      JSON.stringify({
        ok: true,
        in_app_created: inAppCreated,
        pushes_sent: pushesSent,
        skipped_users: skipped,
      }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  } catch (error) {
    return new Response(
      JSON.stringify({
        error: "internal_error",
        message: String(error instanceof Error ? error.message : error),
      }),
      {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      },
    );
  }
});
