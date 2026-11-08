import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";
import { deliver } from "../_shared/notification_delivery.ts";
import { notificationWorkerAuthorized } from "../_shared/notification_worker_auth.ts";
import { reminderDays, remindersEnabled } from "./reminder.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  // Se è un webhook da pg_cron, possiamo verificare un token o header
  // SECURITY: Require Service Role Key
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
    const supabaseClient = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "" // Deve essere service_role per leggere tutto
    );

    const now = new Date();
    // Broad UTC window; the calendar-day filter below uses Europe/Rome and
    // remains correct for evening events and daylight-saving transitions.
    const end = new Date(now.getTime() + 8 * 86400000);
    const { data: attendees, error: attendeesError } = await supabaseClient
      .from("event_attendees")
      .select(`
        user_id,
        status,
        users!inner ( fcm_token, push_enabled, push_settings ),
        events!inner ( id, name, event_date, venue_name )
      `)
      .in('status', ['going', 'maybe'])
      .gte('events.event_date', now.toISOString())
      .lte('events.event_date', end.toISOString());

    if (attendeesError) {
      throw attendeesError;
    }

    const notifications: { userId: string; token: string | null; days: number; title: string; body: string; eventId: string }[] = [];

    // 2. Filtra gli eventi per quelli esattamente a +1 o +7 giorni o oggi
    for (const record of attendees) {
      const user = record.users as unknown as {
        fcm_token: string | null;
        push_enabled: boolean | null;
        push_settings: Record<string, boolean> | null;
      };
      if (!remindersEnabled(user)) continue;
      const fcmToken = user.fcm_token;
      const diffDays = reminderDays((record.events as any).event_date, now);
      if (diffDays === null) continue;

      let title = "";
      let body = "";

      if (diffDays === 7) {
        title = "Promemoria Evento";
        body = `L'evento "${(record.events as any).name}" è tra una settimana!`;
      } else if (diffDays === 1) {
        title = "Domani è il giorno!";
        body = `Non dimenticare: "${(record.events as any).name}" domani a ${(record.events as any).venue_name || 'Vibra'}.`;
      } else if (diffDays === 0) {
        title = "Ci siamo quasi!";
        body = `L'evento "${(record.events as any).name}" è oggi! Preparati!`;
      }

      if (title && body) {
        notifications.push({
          userId: record.user_id,
          token: fcmToken,
          days: diffDays,
          title,
          body,
          eventId: (record.events as any).id,
        });
      }
    }

    let sent = 0;
    let created = 0;
    for (const notif of notifications) {
      // One policy for every notification (record_notification): stored
      // in-app, pushed only if the user's preferences, quiet hours and caps
      // allow it. The group key keeps reruns from stacking duplicates.
      try {
        const result = await deliver(supabaseClient, {
          userId: notif.userId,
          type: 'event_reminder',
          title: notif.title,
          body: notif.body,
          groupKey: `reminder:${notif.eventId}:${notif.days}`,
          data: { event_id: String(notif.eventId), reminder: 'true', reminder_days: String(notif.days) },
        });
        if (!result.stored || result.grouped) continue;
        created++;
        if (result.pushed) sent++;
      } catch (e: any) {
        // The unique reminder key makes reruns safe.
        if (e?.code === '23505') continue;
        throw e;
      }
    }

    return new Response(JSON.stringify({ success: true, count: created, sent }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
      status: 200,
    });
  } catch (error: any) {
    console.error("Error in event-reminders:", error);
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
      status: 500,
    });
  }
});
