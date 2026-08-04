import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

// Interfaccia per i dati attesi dal DB
interface ReminderData {
  user_id: string;
  event_id: string;
  fcm_token: string | null;
  event_name: string;
  event_date: string;
  venue_name: string | null;
  status: string;
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  // Se è un webhook da pg_cron, possiamo verificare un token o header
  const authHeader = req.headers.get("Authorization");
  if (!authHeader || authHeader !== `Bearer ${Deno.env.get("SUPABASE_ANON_KEY")}`) {
      // In produzione proteggere questa route con un service_role key o un secret
  }

  try {
    const supabaseClient = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "" // Deve essere service_role per leggere tutto
    );

    // 1. Troviamo gli eventi imminenti (es. 1 giorno o 7 giorni). 
    // Questa è una query semplificata. In Postgres sarebbe meglio calcolarlo con SQL,
    // ma qui lo facciamo caricando i dati.
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    
    const oneDayFromNow = new Date(today);
    oneDayFromNow.setDate(oneDayFromNow.getDate() + 1);

    const sevenDaysFromNow = new Date(today);
    sevenDaysFromNow.setDate(sevenDaysFromNow.getDate() + 7);
    
    // Per semplicità, richiamiamo una RPC personalizzata o facciamo una JOIN tramite API
    // Se non abbiamo una RPC, facciamo le chiamate necessarie (ma attenzione alla scalabilità).
    // In questo esempio, ipotizziamo una query che recupera gli eventi in arrivo e i partecipanti:
    const { data: attendees, error: attendeesError } = await supabaseClient
      .from("event_attendees")
      .select(`
        user_id,
        status,
        users!inner ( fcm_token, push_settings ),
        events!inner ( id, name, event_date, venue_name )
      `)
      .in('status', ['going', 'maybe'])
      .gte('events.event_date', today.toISOString())
      .lte('events.event_date', sevenDaysFromNow.toISOString());

    if (attendeesError) {
      throw attendeesError;
    }

    const notifications: { token: string; title: string; body: string }[] = [];

    // 2. Filtra gli eventi per quelli esattamente a +1 o +7 giorni o oggi
    for (const record of attendees) {
      const pushSettings = (record.users as any).push_settings || {};
      
      // Controllo che le notifiche siano attive per gli eventi
      // Se l'utente ha disabilitato event_alert, ignoriamo
      if (pushSettings['event_alert'] === false) {
        continue;
      }
      
      const fcmToken = (record.users as any).fcm_token;
      if (!fcmToken) continue;

      const eventDate = new Date((record.events as any).event_date);
      const diffTime = Math.abs(eventDate.getTime() - today.getTime());
      const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24)); 

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
          token: fcmToken,
          title,
          body,
        });
      }
    }

    // 3. Invio notifiche (es. via FCM - richiede chiave server o Firebase Admin SDK)
    // Per lo scope di questo esempio, limitiamoci a stamparle nei log o usare un servizio push.
    console.log(`Prepared ${notifications.length} notifications to send.`);
    
    // Esempio fittizio di invio FCM
    /*
    for (const notif of notifications) {
       await fetch('https://fcm.googleapis.com/fcm/send', {
         method: 'POST',
         headers: {
           'Content-Type': 'application/json',
           'Authorization': `key=${Deno.env.get("FCM_SERVER_KEY")}`
         },
         body: JSON.stringify({
           to: notif.token,
           notification: { title: notif.title, body: notif.body }
         })
       });
    }
    */

    return new Response(JSON.stringify({ success: true, count: notifications.length }), {
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
