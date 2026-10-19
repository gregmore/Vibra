import { corsHeaders, handleOptions } from "../_shared/cors.ts";
import { createSupabaseServiceClient } from "../_shared/supabase.ts";
import { sendFcm } from "../_shared/fcm.ts";
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
  kind: "message" | "friendship" | "match";
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
    if (payload.type !== "INSERT") {
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
        recipients.push({ userId: receiverId, actorId: requesterId, kind: "friendship" });
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

    for (const recipient of uniqueRecipients) {
      const [{ data: targetUser, error: targetError }, { data: actor, error: actorError }] =
        await Promise.all([
          supabase
            .from("users")
            .select("fcm_token, push_settings, push_enabled")
            .eq("id", recipient.userId)
            .maybeSingle(),
          supabase
            .from("users")
            .select("username, display_name")
            .eq("id", recipient.actorId)
            .maybeSingle(),
        ]);

      if (targetError) throw targetError;
      if (actorError) throw actorError;
      if (!targetUser) {
        skipped.push(recipient.userId);
        continue;
      }

      const actorName = actor?.display_name ?? actor?.username ?? "Un utente";
      let notificationType = "chat_message";
      let actionKey = "chat";
      let title = `Nuovo messaggio da ${actorName}`;
      let body = String(record.content ?? "").slice(0, 100);

      if (recipient.kind === "message") {
        const isFriend = await usersAreFriends(supabase, recipient.userId, recipient.actorId);
        if (!isFriend) {
          notificationType = "message_request";
          title = `Nuova richiesta di messaggio da ${actorName}`;
        }
      } else if (recipient.kind === "friendship") {
        notificationType = "friend_request";
        actionKey = "friend_request";
        title = "Nuova richiesta Vibra";
        body = `${actorName} ti ha inviato una richiesta di connessione.`;
      } else {
        notificationType = "match";
        actionKey = "match";
        title = "Nuova affinità trovata!";
        body = `Hai un'affinità del ${Math.round(Number(record.compatibility ?? 0))}% con ${actorName}.`;
      }

      // An in-app notification is useful even if the device has no FCM token
      // or push is disabled. Push preferences affect delivery, not history.
      const { error: notificationError } = await supabase.from("notifications").insert({
        user_id: recipient.userId,
        type: notificationType,
        title,
        body,
        data: {
          sender_id: recipient.actorId,
          record_id: record.id ?? null,
        },
        read: false,
      });
      if (notificationError) throw notificationError;
      inAppCreated++;

      const settings = targetUser.push_settings ?? {};
      const canPush =
        Boolean(targetUser.fcm_token) &&
        targetUser.push_enabled !== false &&
        settings[actionKey] !== false;

      if (canPush) {
        const sent = await sendFcm(targetUser.fcm_token, title, body, {
          type: notificationType,
          sender_id: recipient.actorId,
          record_id: String(record.id ?? ""),
        });
        if (sent) pushesSent++;
      }
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
