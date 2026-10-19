import { rejectRevokedSession } from "../_shared/session-guard.ts";
import { corsHeaders, handleOptions } from "../_shared/cors.ts";
import { requireEnv } from "../_shared/env.ts";
import { createSupabaseServiceClient } from "../_shared/supabase.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.45.4";

Deno.serve(async (req) => {
  const preflight = handleOptions(req);
  if (preflight) return preflight;
  if (req.method !== "POST") return new Response(JSON.stringify({ error: "method_not_allowed" }), {
    status: 405, headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
  const rejected = await rejectRevokedSession(req, "spotify-disconnect");
  if (rejected) return rejected;
  const userClient = createClient(requireEnv("SUPABASE_URL"), requireEnv("SUPABASE_ANON_KEY"), {
    auth: { persistSession: false }, global: { headers: { Authorization: req.headers.get("Authorization") ?? "" } },
  });
  const { data: { user } } = await userClient.auth.getUser();
  if (!user) return new Response(JSON.stringify({ error: "Unauthorized" }), { status: 401, headers: corsHeaders });
  const admin = createSupabaseServiceClient();
  const { error } = await admin.rpc("disconnect_spotify_account", { p_user_id: user.id });
  if (error) return new Response(JSON.stringify({ error: "spotify_disconnect_failed" }), { status: 500, headers: corsHeaders });
  return new Response(JSON.stringify({ success: true }), { headers: { ...corsHeaders, "Content-Type": "application/json" } });
});
