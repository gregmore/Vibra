import { corsHeaders, handleOptions } from "../_shared/cors.ts";
import { createSupabaseServiceClient } from "../_shared/supabase.ts";
import { sendFcmLegacy } from "../_shared/fcm.ts";

type WebhookPayload = {
  type: "INSERT" | "UPDATE" | "DELETE";
  table: string;
  record: any;
  schema: string;
};

Deno.serve(async (req) => {
  const preflight = handleOptions(req);
  if (preflight) return preflight;

  try {
    if (req.method.toUpperCase() !== "POST") {
      return new Response(JSON.stringify({ error: "Method not allowed" }), {
        status: 405,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const payload: WebhookPayload = await req.json();
    if (payload.type !== "INSERT") {
      return new Response(JSON.stringify({ ok: true, ignored: true }), {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const supabase = createSupabaseServiceClient();
    const record = payload.record;
    let targetUserId = null;
    let senderUserId = null;
    let title = "";
    let body = "";
    let notificationType = "";
    let actionKey = "";

    if (payload.table === "messages") {
      targetUserId = record.receiver_id;
      senderUserId = record.sender_id;
      actionKey = "chat";
      notificationType = "chat_message";
    } else if (payload.table === "friendships") {
      targetUserId = record.receiver_id;
      senderUserId = record.requester_id;
      actionKey = "friend_request";
      notificationType = "friend_request";
    } else if (payload.table === "user_matches") {
      // Per i match, avvisiamo user_id_b dell'affinità con user_id_a (triggerato da A o dal sistema)
      // oppure notifichiamo entrambi. Semplifichiamo notificando user_id_b.
      targetUserId = record.user_id_b;
      senderUserId = record.user_id_a;
      actionKey = "match";
      notificationType = "match";
    } else {
      return new Response(JSON.stringify({ ok: true, skipped: "Table not supported" }), {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    if (!targetUserId || !senderUserId) {
      return new Response(JSON.stringify({ ok: true, skipped: "Missing user IDs" }), {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // Carica target user
    const { data: targetUser } = await supabase
      .from("users")
      .select("fcm_token, push_settings, push_enabled")
      .eq("id", targetUserId)
      .single();

    if (!targetUser || !targetUser.fcm_token) {
      return new Response(JSON.stringify({ ok: true, skipped: "No FCM token" }), {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // Controlla settings
    if (targetUser.push_enabled === false) {
      return new Response(JSON.stringify({ ok: true, skipped: "Push disabled globally" }), {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }
    const settings = targetUser.push_settings || {};
    if (settings[actionKey] === false) {
      return new Response(JSON.stringify({ ok: true, skipped: `Push disabled for ${actionKey}` }), {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // Carica sender info
    const { data: senderUser } = await supabase
      .from("users")
      .select("username")
      .eq("id", senderUserId)
      .single();

    const senderName = senderUser?.username ?? "Un utente";

    // Costruisci payload Push e In-App
    if (payload.table === "messages") {
      title = `Nuovo messaggio da ${senderName}`;
      body = record.content.length > 100 ? record.content.substring(0, 97) + "..." : record.content;
    } else if (payload.table === "friendships") {
      title = "Nuova richiesta Vibra";
      body = `${senderName} ti ha inviato una richiesta di connessione.`;
    } else if (payload.table === "user_matches") {
      title = "Nuova affinità trovata!";
      body = `Hai un'affinità del ${Math.round(record.compatibility)}% con ${senderName}.`;
    }

    // Push FCM
    const ok = await sendFcmLegacy(targetUser.fcm_token, title, body, {
      type: notificationType,
      sender_id: senderUserId,
      record_id: record.id,
    });

    // In-App Notification (per match e amicizie)
    if (payload.table !== "messages") {
      await supabase.from("notifications").insert({
        user_id: targetUserId,
        type: notificationType,
        title: title,
        body: body,
        data: {
          sender_id: senderUserId,
          record_id: record.id,
        },
        read: false,
      });
    }

    return new Response(
      JSON.stringify({
        ok: true,
        pushed: ok,
      }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  } catch (e: any) {
    return new Response(
      JSON.stringify({
        error: "internal_error",
        message: e.message,
      }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});
