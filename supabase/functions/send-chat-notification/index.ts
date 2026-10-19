import { corsHeaders, handleOptions } from "../_shared/cors.ts";
import { createSupabaseServiceClient } from "../_shared/supabase.ts";
import { sendFcm } from "../_shared/fcm.ts";
import { notificationWorkerAuthorized } from "../_shared/notification_worker_auth.ts";

type LiveMessageRecord = {
  id: string;
  event_id: string;
  user_id: string;
  content: string;
  created_at: string;
};

type WebhookPayload = {
  type: "INSERT" | "UPDATE" | "DELETE";
  table: string;
  record: LiveMessageRecord;
  schema: string;
};

// Raggio d'azione in metri (5 km), applicato dal database con PostGIS.
const MAX_RADIUS_METERS = 5000;

Deno.serve(async (req) => {
  const preflight = handleOptions(req);
  if (preflight) return preflight;

  // SECURITY: Verify the request is authorized (e.g. from internal webhook or cron)
  if (!await notificationWorkerAuthorized(req)) {
    return new Response(JSON.stringify({ error: "Unauthorized" }), {
      status: 401,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }


  try {
    if (req.method.toUpperCase() !== "POST") {
      return new Response(JSON.stringify({ error: "Method not allowed" }), {
        status: 405,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const payload: WebhookPayload = await req.json();

    if (payload.type !== "INSERT" || payload.table !== "live_messages") {
      return new Response(JSON.stringify({ ok: true, ignored: true }), {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const record = payload.record;
    const supabase = createSupabaseServiceClient();

    // 1. Recupera i dettagli dell'evento per sapere la sua posizione e il nome
    const { data: eventData, error: eventError } = await supabase
      .from("events")
      .select("id, name, latitude, longitude")
      .eq("id", record.event_id)
      .single();

    if (eventError || !eventData) {
      throw new Error(`Evento non trovato: ${record.event_id}`);
    }

    if (typeof eventData.latitude !== "number" || typeof eventData.longitude !== "number") {
      return new Response(JSON.stringify({ ok: true, skipped: "Event has no coordinates" }), {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // 2. Recupera lo username del mittente
    const { data: senderData } = await supabase
      .from("users")
      .select("username")
      .eq("id", record.user_id)
      .single();

    const senderName = senderData?.username ?? "Un utente";

    // 3. Recupera solo i destinatari entro 5 km con ST_DWithin. La notifica
    // in-app non dipende dal fatto che il dispositivo abbia FCM.
    const { data: users, error: usersError } = await supabase
      .rpc("live_chat_notification_recipients", {
        p_event_id: eventData.id,
        p_exclude_user_id: record.user_id,
        p_radius_meters: MAX_RADIUS_METERS,
      });

    if (usersError) throw usersError;

    let pushed = 0;
    const title = `Nuovo messaggio per l'evento ${eventData.name}`;
    let body = `${senderName}: ${record.content}`;

    // Truncate message body if too long
    if (body.length > 100) {
      body = body.substring(0, 97) + "...";
    }

    const notificationsToInsert = [];

    for (const user of (users || [])) {
      if (user.push_settings?.live_chat === false) continue;

      notificationsToInsert.push({
        user_id: user.id,
        type: 'live_chat',
        title: title,
        body: body,
        data: {
          event_id: eventData.id,
          message_id: record.id,
        },
        read: false,
      });

      if (user.fcm_token && user.push_enabled !== false) {
        const ok = await sendFcm(
          user.fcm_token,
          title,
          body,
          {
            type: "live_chat",
            event_id: eventData.id,
            message_id: record.id,
          }
        );
        if (ok) pushed++;
      }
    }

    // 5. Salva log notifiche nel DB
    if (notificationsToInsert.length > 0) {
      await supabase.from("notifications").insert(notificationsToInsert);
    }

    return new Response(
      JSON.stringify({
        ok: true,
        event_id: eventData.id,
        notified_users: pushed,
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
