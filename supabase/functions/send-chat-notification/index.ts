import { corsHeaders, handleOptions } from "../_shared/cors.ts";
import { createSupabaseServiceClient } from "../_shared/supabase.ts";
import { haversineKm } from "../_shared/geo.ts";
import { sendFcmLegacy } from "../_shared/fcm.ts";

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

// Raggio d'azione in chilometri (5 km)
const MAX_RADIUS_KM = 5.0;

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

    // 3. Recupera tutti gli utenti che hanno un FCM token e delle coordinate recenti (escludendo il mittente)
    // Selezioniamo a blocchi o con limite ragionevole per prototipo
    const { data: users, error: usersError } = await supabase
      .from("users")
      .select("id, fcm_token, last_latitude, last_longitude")
      .neq("id", record.user_id)
      .not("fcm_token", "is", null)
      .not("last_latitude", "is", null)
      .not("last_longitude", "is", null);

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
      if (!user.last_latitude || !user.last_longitude || !user.fcm_token) continue;

      // 4. Filtra tramite distanza Haversine
      const distance = haversineKm(
        eventData.latitude,
        eventData.longitude,
        user.last_latitude,
        user.last_longitude
      );

      if (distance <= MAX_RADIUS_KM) {
        // Prepara la notifica push
        const ok = await sendFcmLegacy(
          user.fcm_token,
          title,
          body,
          {
            type: "chat_message",
            event_id: eventData.id,
            message_id: record.id,
          }
        );

        if (ok) {
          pushed++;
          // Aggiunge la notifica in-app da inserire nel DB
          notificationsToInsert.push({
            user_id: user.id,
            type: 'event_alert', // Reuse event_alert or use a new type if we add it to schema constraint
            title: title,
            body: body,
            data: {
              event_id: eventData.id,
              message_id: record.id,
            },
            read: false,
          });
        }
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
